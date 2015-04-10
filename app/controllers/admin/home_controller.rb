class Admin::HomeController < Admin::AdminController
  skip_authorization_check
  def index
  end
end
