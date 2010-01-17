class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5e49bedcc578570fc00e25637e1d7794'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def self.backlog
    request.env["HTTP_X_HEROKU_QUEUE_DEPTH"]
  end
  
  def dynos
    request.env["HTTP_X_HEROKU_DYNOS_IN_USE"]
  end
  
  
end
