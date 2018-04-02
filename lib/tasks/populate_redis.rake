task :populate_local_redis do
  types = {"used" => 0, "new" => 1, "trade-in" => 2, "amazon" => 3}
  until types.empty?
    response = HTTParty.get("http://price-production.sjcukk54cx.us-west-2.elasticbeanstalk.com/prices/#{types.keys.first}/all?asins=#{ENV["ASIN"]}").parsed_response
    tt = types.delete(types.keys.first)
    puts tt
    Redis.new(url: "redis://127.0.0.1:6379/#{tt}").del(response.keys.first)
    response[response.keys.first].each do |k,v|
      Redis.new(url: "redis://127.0.0.1:6379/#{tt}").hset(response.keys.first, k, v)
    end
  end
end
