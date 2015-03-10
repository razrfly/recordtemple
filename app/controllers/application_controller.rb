class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url

   @resource = User.new
   @devise_mapping = Devise.mappings[:user]
   @resource_name =  :user

  end
end
