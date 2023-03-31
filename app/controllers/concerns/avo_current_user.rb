module AvoCurrentUser
  extend ActiveSupport::Concern
  include Passwordless::ControllerHelpers

  #helper_method :current_user

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

end