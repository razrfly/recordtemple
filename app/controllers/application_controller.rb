class ApplicationController < ActionController::Base
  include Pundit

  before_action :store_current_location,
    :unless => :devise_controller?

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def after_sign_out_path_for(resource)
    request.referrer || root_path
  end
end
