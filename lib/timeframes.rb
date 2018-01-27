class Timeframes
  class << self
    def defaults
      {"used" => :yearly, "trade" => :seasonal}
    end

    def seasonal
      {"Winter/Spring" => ["1480575600", "1496296800"], "Summer/Fall" => ["1498888800", "1509516000"]}
    end

    def yearly
      {"Yearly" => [1.year.ago.to_i.to_s, Time.now.to_i.to_s]}
    end
  end
end
