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

  def type_valid?
    %w(used new trade amazon).include?(params[:type])
  end

  def check_params
    errors = []
    errors << "You must include at list one ASIN" unless params.has_key?(:asins)
    errors << "price type '#{params[:type]}' is not permitted" unless type_valid?
    render json: {errors: errors} if errors
  end
end
