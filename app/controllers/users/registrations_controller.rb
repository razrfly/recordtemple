class Users::RegistrationsController < Devise::RegistrationsController
  layout 'admin/application', only: [:edit, :update, :destroy]

  protected
    # You can put the params you want to permit in the empty array.
    def configure_account_update_params
      devise_parameter_sanitizer.for(:account_update) << [:username, :fname, :lname]
    end

    def after_update_path_for(resource)
      admin_user_url(current_user)
    end

end

