class PagesController < ApplicationController
  before_action :set_user

  def index
    @pages = @user.nil? ? Page.all : @user.pages
  end


  def show
    if @user
      @page = @user.pages.find_by(slug: params[:id])
    else
      raise ActionController::RoutingError.new('Not Found') if @page.blank?
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id]) unless params[:user_id].nil?
    end

end
