class RedisHistory
  def initialize(asins, type)
    @asins = asins
    @type = type
  end

  def all
    result = {}
    redis.pipelined do
      @asins.each do |asin|
        history = redis.hgetall asin
        result[asin] = history
      end
    end
    result.each do |k,v|
      RedisClient.missing.set(k, Time.now.to_i) if v.value.empty?
      result[k] = v.value
    end
    result
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

  def edge_value(opt)
    result = {}
    all.each do |asin, history|
      result[asin] = history.values.empty? ? nil : [history.sort_by{|k,v| v.to_i}.send(opt)].to_h
    end
    result
  end

  def by_timeframe(timeframe)
    result = hash_tree
    seasons = Timeframes.send(timeframe)
    seasons.each do |season, timestamps|
      lower, upper = timestamps
      selected = all.map{|k,v| [k, v.select{|time, value| time.to_s.between?(lower, upper)}] }.to_h
      selected.each do |asin, history|
        if history.values.any?
          sorted = history.sort_by{|k,v| v.to_i}
          res = {
            average: history.sum {|time, rank| rank.to_i } / history.size,
            highest: {sorted.last.first => sorted.last.last},
            lowest: {sorted.first.first => sorted.first.last},
          }
          result[asin][@type][season] = res
        else
          result[asin] = {}
        end
      end
    end
    result
  end

  def hash_tree
    Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
  end

  def redis
    @redis ||= RedisClient.send(@type)
  end
end

