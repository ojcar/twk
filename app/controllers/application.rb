# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '307b8a34c931d02b46ef87ce7449305c'
  include AuthenticatedSystem
  before_filter :login_from_cookie
  #around_filter :set_timezone
  
  #private
  #  def set_timezone
  #    TzTime.zone = current_user.time_zone
  #    yield
  #    TzTime.reset!
  #  end
end
