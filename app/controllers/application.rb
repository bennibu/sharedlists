# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  before_filter :authenticate
  
  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == 'admin' && password == APP_CONFIG[:admin_password]
    end
  end
end
