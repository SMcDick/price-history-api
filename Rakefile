# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :add_proxy_uris_to_redis do
  if ENV["PROXY_URIS"]
    ENV["PROXY_URIS"].split(",").each do |uri|
      redis = Redis.new(url: "redis://prices.xecwrb.ng.0001.usw2.cache.amazonaws.com:6379/5")
      redis.zadd("proxies", Time.now.to_i, uri)
    end
  end
end
