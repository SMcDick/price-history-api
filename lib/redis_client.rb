class RedisClient
  class << self
    [:used, :new, :trade, :amazon].each do |type|
      define_method :"#{type}" do
        self.redis("#{base}/#{self.db(type)}")
      end
    end

    def base
      ENV["REDIS_BASE_URI"]
    end

    def missing
      self.redis(ENV["REDIS_MISSING_ASIN_URI"])
    end

    def db(type)
      {used: 12, new: 13, trade: 14, amazon: 15}[type]
    end

    def redis(db)
      Redis.new(url: db)
    end
  end
end
