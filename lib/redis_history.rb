class RedisHistory
  def initialize(asins, type, max_age)
    @asins = asins
    @type = type
    @max_age = max_age.to_i
    @minimum_age = 60.days.ago
  end

  def all
    result = {}
    # redis.pipelined do
      @asins.each do |asin|
        history = Rails.cache.fetch(asin, expires_in: 24.hours){ redis.hgetall asin }
        result[asin] = history
      end
    # end
    result.each do |k,v|
      # RedisClient.missing.set(k, Time.now.to_i) if v.value.empty?
      result[k] = v.select{|k,v| k.to_i > @max_age}
    end
    result
  end

  def last_year
    selected = all.map{|k,v| [k, this_month_last_year(v)] }.to_h
    averages(selected)
  end

  def averages(data=nil)
    averages = {}
    data = data.nil? ? all : data
    data.each do |asin, history|
      begin
        averages[asin] = history.sum {|time, rank| rank.to_i } / history.size
      rescue ZeroDivisionError
        averages[asin] = nil
      end
    end
    averages
  end

  def highest_and_lowest
    result = {}
    all.each do |asin, history|
      result[asin] = history.any? ? extrema(history) : nil
    end
    result
  end

  def by_timeframe(timeframe)
    result = hash_tree
    seasons = Timeframes.send(timeframe)
    data = all
    seasons.each do |season, timestamps|
      lower, upper = timestamps
      selected = data.map{|k,v| [k, v.select{|time, value| time.to_s.between?(lower, upper)}] }.to_h
      selected.each do |asin, history|
        if history.values.any?
          result[asin][@type][season] = extrema(history)
        else
          result[asin] = {}
        end
      end
    end
    result
  end

  def meta
    result = {}
    all.each do |asin, history|
      timestamps = history.keys
      first, last = Time.at(timestamps.min.to_i), Time.at(timestamps.max.to_i)
      result[asin] = {
        first_appeared: first,
        last_logged: last,
        eligible_for_averages: first < @minimum_age,
        history_size: timestamps.size
      }
    end
    result
  end

  def hash_tree
    Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
  end

  def redis
    @redis ||= RedisClient.send(@type)
  end

  private

  def this_month_last_year(value)
    value.select do |k,v|
      ts = Time.at(k.to_i)
      ts.year == 1.year.ago.year && ts.month == Time.now.month
    end
  end

  def extrema(history)
    sorted = history.sort_by{|k,v| v.to_i}
    {
      average: sorted.sum{|h| h.last.to_i} / sorted.size,
      lowest: {recorded_at: sorted.first.first, price: sorted.first.last},
      highest: {recorded_at: sorted.last.first, price: sorted.last.last}
    }
  end
end

