class PagesController < ApplicationController

  def index
    @pages = Page.where(user_id: current_user.id)
  end


  def show
    if params[:user_id]
      user = User.find(params[:user_id])
      @page = user.pages.find_by(slug: params[:id])
    # else
      # @page = Page.find_by(slug: params[:id])
    end
    raise ActionController::RoutingError.new('Not Found') if @page.blank?
  end

end
