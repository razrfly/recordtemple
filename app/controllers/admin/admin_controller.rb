class Admin::AdminController < ActionController::Base
  layout 'admin/application'
  before_action :authenticate_user!
  before_action :set_nav

  def sticky
    if params[:stick_action] == "stick"
      cookies.permanent["nav_#{current_user.id}"] = 'sticked'
    elsif params[:stick_action] == "unstick"
      cookies.permanent["nav_#{current_user.id}"] = 'unsticked'
    end
    render json: {}
  end


  private
    def set_nav
      @pinned = cookies["nav_#{current_user.id}"] == 'sticked' ? true : false
    end

end
