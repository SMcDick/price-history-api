class RedisClient
  class << self
    def missing
      self.redis(ENV["REDIS_MISSING_ASIN_URI"])
    end

    def used
      self.redis("#{base}/#{self.db}")
    end

    def new
      self.redis("#{base}/#{self.db}")
    end

    def trade
      self.redis("#{base}/#{self.db}")
    end

    def amazon
      self.redis("#{base}/#{self.db}")
    end

    def base
      ENV["REDIS_BASE_URI"]
    end

    def db
      _caller = caller_locations(1,1)[0].label
      {used: 0, new: 1, trade: 2, amazon: 3}[_caller]
    end

    def redis(db)
      Redis.new(url: db)
    end
  end
end
