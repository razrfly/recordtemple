class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5e49bedcc578570fc00e25637e1d7794'
  
  helper_method :backlog, :dynos, :new_dyno, :saveme
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private
  
  def backlog
    request.env["HTTP_X_HEROKU_QUEUE_DEPTH"].to_i
  end
  
  def dynos
    request.env["HTTP_X_HEROKU_DYNOS_IN_USE"]
  end
  
  def new_dyno
    @client = Heroku::Client.new('holden.thomas@gmail.com','sawyer')
    @client.set_dynos('recordapp', 2)
  end
  
  def saveme
    if backlog > 10
      new_dyno
    end
  end
  
  
end
