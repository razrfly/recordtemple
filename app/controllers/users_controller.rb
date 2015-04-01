class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.all
  end

  def show
    @photos = @user.photos.limit(20)
    @records = @user.records
  end

  private
    def set_user
      @user = params[:user_id].present? ? User.find(params[:user_id]) : User.find(params[:id])
    end

end
