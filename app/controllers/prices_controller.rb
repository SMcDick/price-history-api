class PricesController < ApplicationController
  before_action :check_params

  def all
    render json: history.all
  end

  def average
  end

  def highest
  end

  def lowest
  end
end
