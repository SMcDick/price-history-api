# require 'redis'
# require 'logger'
# require 'pry'

# task :clean_redis do
#   # puts redis.info["used_memory_human"]
  # $redis = RedisClient.used

#   mutex = Mutex.new
#   logger = Logger.new('output.log')
#   before = $redis.hgetall $redis.keys.first
#   cursor = 0
#   all_days = build_days
#   # 2.times.map do
#     # Thread.new do
#       asins = [0]
#       while asins.any?
#
#         # mutex.synchronize do
#           cursor, asins = $redis.scan(cursor)
#         # end
#         asins.each do |asin|
#           data = $redis.hgetall(asin)
#
#           next if data.size < 12
#           data.keys.each do |k|
#             data[Time.at(k.to_i)] = data.delete(k)
#           end
#           data = data.sort_by {|k,v| k}
#           cleaned = {}
#           data = data.uniq{|d| d.first.strftime("%B %d, %Y")}
#
#           data.each do |date, value|
#
#             cleaned[date.to_i] = value.to_i
#           end
#
#           $redis.del(asin)
#           $redis.hmset(asin, *cleaned) if cleaned.any?
#         end
#         binding.pry
#         logger.info $redis.info["used_memory_human"]
#       end
#     # end
#   # end.each(&:join)
# end

# def build_days
#   days = []
#   365.times do |t|
#     days << t.days.ago
#   end
#   days
# end



##############

# require 'redis'

# def all_for_asin(asin)
#   $redis.hgetall(asin)
# rescue Redis::CommandError
#   # logger.debug(asin)
#   []
# end

# def average(data)
#   data.values.map(&:to_i).inject(&:+) / data.size
# end

# def new_average(data)
#   values = data.values.map{|i| JSON.parse(i)}
#   # binding.pry
#   total_count = values.map{|i| i["count"]}.sum
#   values.map{|i| i["total"]}.sum / total_count
# end

# task :compact do
#   $redis = RedisClient.amazon
#   cursor = 0
#   asins = [0]
#   while asins.any?
#     cursor, asins = $redis.scan(cursor)
#     # binding.pry
#     asins.each do |asin|
#       data = all_for_asin(asin)
#       raw = data.dup
#       next if data.size < 12
#       data.keys.each{ |k| data[Time.at(k.to_i)] = data.delete(k)} # replace str timestamp with time obj
#       data = data.sort_by {|k,v| k} # sort data by time asc
#       months = {}
#       current_month = data.first.first.beginning_of_month

#       data.each do |date, value|
#         months[current_month.to_i] ||= []
#         if date < current_month
#           months[current_month.to_i] << value.to_i
#         else
#           current_month = current_month + 1.month
#           redo
#         end
#       end

#       months.keys.each do |k|
#         sum = months[k].inject(&:+).to_i
#         months[k] = {total: sum, count: months[k].size}.to_json
#         months.delete(k) if sum.zero?
#       end

#       # binding.pry
#       raw_avg = average(raw)
#       months_avg = new_average(months)
#       binding.pry
#       puts "asin #{asin} raw avg #{raw_avg} months_avg #{months_avg}"
#       # $redis.del(asin)
#       # $redis.hmset(asin, *months) if months.any?
#     end
#   end #.each(&:join)
# end



require 'redis'
require 'logger'

task :compact do
  redis = RedisClient.trade
  n_redis = RedisClient.n_trade
  # puts redis.info["used_memory_human"]
  cursor = 0
  asins = [0]
  while asins.any?
    cursor, asins = redis.scan(cursor)
    asins.each do |asin|
      data = begin
        redis.hgetall(asin)
      rescue Redis::CommandError
        []
      end
      data.keys.each{ |k| data[Time.at(k.to_i)] = data.delete(k)}
      data = data.sort_by {|k,v| k}
      months = {}
      current_month = data.first.first.beginning_of_month
      data.each do |date, value|
        months[current_month.to_i] ||= []
        if date < current_month
          months[current_month.to_i] << value.to_i
        else
          current_month = current_month + 1.month
          redo
        end
      end

      months.keys.each do |k|
        sum = months[k].inject(&:+).to_i
        months[k] = {total: sum, count: months[k].size}.to_json
        months.delete(k) if sum.zero?
      end

      # redis.del(asin)
      puts n_redis.hmset(asin, *months) if months.any?
    end
  end
end

