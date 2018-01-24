class PricesController < ApplicationController
  before_action :check_params

  def all
    render json: history.all
  end

  def average
    render json: history.averages
  end

  def highest
  end

  def lowest
  end
end
