class Admin::UsersController < Admin::AdminController
  authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @search = User.ransack(params[:q])
    @users = @search.result.page(params[:page])
    @invitation = Invitation.new
    respond_to do |format|
      format.html
      format.json {
        render json: @users.to_json(only: [:name, :id]) }
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User was successfully deleted."
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :fname, :lname)
    end
end
