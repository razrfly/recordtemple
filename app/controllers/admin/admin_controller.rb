class Admin::AdminController < ActionController::Base
  layout 'admin/application'
  before_action :authenticate_user!
end
