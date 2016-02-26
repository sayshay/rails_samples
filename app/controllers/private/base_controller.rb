class Api::Private::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate

protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == 'admin' && password == 'festivals'
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    head :not_found
  end

end
