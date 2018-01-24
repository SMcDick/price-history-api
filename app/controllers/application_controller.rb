class ApplicationController < ActionController::API
  after_action :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def asins
    params[:asins].split(",")
  end

  def history
    RedisHistory.new(asins, params[:type])
  end

  def check_params
    render json: {error: "You must include at list one ASIN"}, status: 400 if params[:asins].nil? || params[:asins].empty?
  end
end
