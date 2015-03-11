class Users::RegistrationsController < Devise::RegistrationsController
  layout 'admin/application', only: [:edit, :update, :destroy]

end
