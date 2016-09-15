class Users::RegistrationsController < Devise::RegistrationsController

  private
  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(
  #     :account_update
  #     ) << [:username, :fname, :lname, :avatar]
  # end

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
