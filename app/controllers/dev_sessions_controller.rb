class DevSessionsController < ApplicationController
  def create
    raise "Dev login only available in development!" unless Rails.env.development?

    user = User.first || User.create!(email: "dev@example.com")
    session = Passwordless::Session.create!(
      authenticatable: user,
      user_agent: request.user_agent || "DevLogin",
      remote_addr: request.remote_ip || "127.0.0.1"
    )
    sign_in(session)

    redirect_to root_path, notice: "Signed in as #{user.email}"
  end
end
