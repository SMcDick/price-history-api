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

  def history(type=nil)
    type = type || params[:type]
    RedisHistory.new(asins, type, timeframe)
  end

  def timeframe
    params[:timeframe]&.respond_to?(:to_i) ? params[:timeframe].to_i.months.ago : 1.year.ago
  end

  def type_valid?
    %w(used new trade amazon).include?(params[:type])
  end

  def check_params
    errors = []
    errors << "You must include at list one ASIN" unless params.has_key?(:asins)
    errors << "price type '#{params[:type]}' is not permitted" unless type_valid?
    render json: {errors: errors} unless errors.empty?
  end
end
