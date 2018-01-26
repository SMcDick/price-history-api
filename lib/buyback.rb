require 'faraday'
require 'faraday_middleware'
require 'faraday-request-timer'

class BuyBack
  attr_accessor :status

  def initialize(response)
    @response = response
    @offers, @top_offer, @asin = set_data if @response.success?
    @status = @response.status
    @requestor = @response.env.request.proxy.uri.to_s.split('//')[-1] if @response.env.request.proxy
    @took = @response.env[:duration]
  end

  def self.connection
    conn = build_connection(ENV["BOOK_SCOUTER_API_BASE_URI"])
    conn.headers = base_headers
    conn
  end

  def self.build_connection(uri)
    conn = Faraday.new(url: uri) do |faraday|
      faraday.request    :json
      faraday.request    :timer
      faraday.response   :json
      faraday.adapter    Faraday.default_adapter
      faraday.proxy      self.select_proxy
    end
  end

  def self.select_proxy
    { uri: "http://#{self.redis.zrange("proxies", 0, 0).first}" }
  end

  def self.base_headers
    {
      "Authorization": "Bearer undefined",
      "Origin": "https://bookscouter.com",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "en-US,en;q=0.9",
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36",
      "Accept": "application/json, text/javascript, */*; q=0.01",
      "X-Requested-With": "XMLHttpRequest",
      "Connection": "keep-alive"
    }
  end

  def self.get_offer(asin)
    begin
      client = connection
      client.headers["Referer"] = "#{ENV['BOOK_SCOUTER_WEB_BASE_URI']}/#{asin}"
      response = client.get(asin)
      requesting_proxy = response.env.request.proxy.uri.to_s.split('//')[-1] rescue nil
      self.redis.zadd("proxies", Time.now.to_i, requesting_proxy)
      new(response)
    rescue Faraday::ConnectionFailed
      puts "error connecting to proxy #{client.proxy.uri.to_s.split('//')[-1]}"
    end
  end

  def set_data
    [@response.body["data"]["Prices"], extract_offer(@response.body["data"]["Prices"]), @response.body["data"]["Book"]["Isbn10"]]
  end

  def to_json
    {asin: @asin, top_offer: @top_offer, took: @took, status: @status}
  end

  def extract_offer(offer)
    offer = offer.reject{|o| o["Vendor"]["Id"] == "54"}.first
    price, vendor = (offer["Price"] * 100).to_i, offer["Vendor"]
    {price: price, vendor_name: vendor["Name"].underscore.humanize.titleize, offer_type: vendor["BuySell"]}
  end

  def self.redis
    @redis ||= Redis.new(url: "redis://prices.xecwrb.ng.0001.usw2.cache.amazonaws.com:6379/5")
  end
end

