class AdminConstraint
  def matches?(request)
    passwordless_session_id = request.session['passwordless_session_id--user']
    return false unless passwordless_session_id

    user = Passwordless::Session.find(passwordless_session_id).authenticatable
    user&.admin?
  end
end