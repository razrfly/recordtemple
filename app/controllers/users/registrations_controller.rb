class Users::RegistrationsController < Devise::RegistrationsController
  layout 'devise/application', only: [:new, :create]

  private

  def after_update_path_for(resource)
    settings_path
  end

  def account_update_params
    params.require(:user).permit(:fname, :lname,
      :avatar, :remove_avatar, :email, :password,
      :password_confirmation, :current_password,
      :username)
  end
end
