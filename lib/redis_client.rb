class RedisClient
  class << self
    [:used, :new, :trade, :amazon, :n_used, :n_new, :n_trade, :n_amazon].each do |type|
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
      {used: 0, new: 1, trade: 2, amazon: 3, n_used: 7, n_new: 8, n_trade: 9, n_amazon: 10}[type]
    end

    def redis(db)
      Redis.new(url: db)
    end
  end
end
