asins = ['','','','','','']

asins.each do |asin|
  categories = {"used" => 0, "new" => 1, "trade-in" => 2, "amazon" => 3}
  until categories.empty?
    response = HTTParty.get("http://price-production.sjcukk54cx.us-west-2.elasticbeanstalk.com/prices/#{categories.keys.first}/all?asins=#{asin}").parsed_response
    category = categories.delete(categories.keys.first)
    redis = Redis.new(url: "redis://127.0.0.1:6379/#{category}")
    redis.del(response.keys.first)
    response[response.keys.first].each {|k,v| redis.hset(response.keys.first, k, v)}
  end
end
