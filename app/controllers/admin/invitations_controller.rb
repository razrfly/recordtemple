class Admin::InvitationsController < Admin::AdminController

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.valid?
      @user = User.invite!(email: @invitation.email)
      redirect_to admin_users_path, notice: 'Invitation was sent.'
    else
      render action: 'new'
    end
  end

end