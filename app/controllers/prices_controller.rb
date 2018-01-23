class PricesController < ApplicationController
  def all
    render json: params[:type]
  end

  def average
    render json: params[:type]
  end

  def highest
    render json: params[:type]
  end

  def lowest
    render json: params[:type]
  end
end
