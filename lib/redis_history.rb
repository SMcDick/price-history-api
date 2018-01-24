class RedisHistory
  def initialize(asins, type)
    @asins = asins
    @type = {"used" => 0, "new" => 1, "trade" => 2, "amazon" => 3, "missing" => 4}[type]
  end

  def all
    result = {}
    self.class.redis.pipelined do
      @asins.each do |asin|
        history = self.class.redis.hgetall asin
        result[asin] = history
      end
    end
    result.each {|k,v| result[k] = v.value }
    result
  end

  def self.redis
    @redis ||= Redis.new(url: "#{ENV["REDIS_URL"]}/#{@type}")
  end
end

