class PricesController < ApplicationController
  before_action :check_params

  def all
    render json: history.all
  end

  def average
    render json: history.averages
  end

  def last_year
    render json: history.last_year
  end

  def extrema
    render json: history.highest_and_lowest
  end

  def average_by_range
    used, trade = Timeframes.defaults.map{|k,v| history(k).by_timeframe(v)}
    result = used.update(trade){|k,o,n| o.merge(n)}
    render json: result
  end
end
