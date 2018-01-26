class BuybackController < ApplicationController

  def index
    response = if params[:skip_cache]
      BuyBack.get_offer(params[:asins])
    else
      Rails.cache.fetch(params[:asins], expires_in: 6.hours) { BuyBack.get_offer(params[:asins]) }
    end
    render json: response.to_json
  end

end
