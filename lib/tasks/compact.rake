# this is the version of the redis-compactor task that we used to
# shrink the rank database. this repo will have some unique challenges,
# like the fact that peter wants the ability to query the db for averages in
# specific date windows (probably ruling out the partition-by-month strategy).
# but for the most part, it should be pretty similar. since the different
# price types are stored in their own redis db's within the same instance,
# we'd do this once for every type. probably bring in the RedisClient class and
# go over the various types, reassigning source and destination each time.

# don't run this as-is, only use it as a guide.

file_logger = Logger.new('log/redis.log')

task :compact do
  source = Redis.new(url: ENV["SRC_REDIS_URL"]) # this is where the current, raw data lives.
  destination = Redis.new(url: ENV["COMPACTED_REDIS_URL"]) # this is the fresh db
  Time.zone = 'UTC' # there were some weird date-time issues in here the first few times we attempted this
  puts "importing from #{source} to #{destination}"
  cursor = 0
  asins = [0]

  while cursor != "0"
    cursor, asins = source.scan(cursor)
    asins.each do |asin|

      data = begin
        source.hgetall(asin) # get the raw data for this asin
      rescue Redis::CommandError
        file_logger.debug("error fetching source data for #{asin}")
        []
      end

      data.keys.each{ |k| data[Time.at(k.to_i)] = data.delete(k)} # reformat the timestamp
      data = data.sort_by {|k,v| k}
      months = {}

      # store by beginning of month
      current_month = Time.zone.at(data.first.first).beginning_of_month

      # split data into months
      data.each do |date, value|
        months[current_month.to_i] ||= []
        if date < current_month
          months[current_month.to_i] << value.to_i
        else
          current_month = current_month + 1.month
          redo
        end
      end

      # now that it's broken up by month, lets shrink it down.
      # we need the total and the number of records, to get a
      # correct weighted average when we're averaging out many
      # months at a time

      months.keys.each do |k|
        sum = months[k].inject(&:+).to_i
        months[k] = {total: sum, count: months[k].size}.to_json
        months.delete(k) if sum.zero?
      end

      # remove the original record from the destination , if one already existed
      # this is useful if you have to run this script more than once
      destination.del(asin)

      # finally, write the new data
      begin
        destination.hmset(asin, *months) if months.any?
      rescue => e
        file_logger.debug("error writing final data(#{asin}): #{e}")
      end
    end
  end
end
