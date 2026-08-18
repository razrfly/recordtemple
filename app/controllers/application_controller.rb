class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers
  include Pagy::Backend
  include Breadcrumbable

  # The collection is single-user; every record belongs to this id. Several
  # controllers define their own copy of this constant — this one exists so
  # views can ask the ownership question without a seventh duplicate.
  COLLECTION_USER_ID = 1

  helper_method :current_user, :collection_owner?

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  # Mirrors RecordsController#require_collection_owner! so owner-only affordances
  # only render when the corresponding request would actually succeed. Note this
  # is deliberately NOT User#admin?, which is hardcoded to return true.
  def collection_owner?
    current_user&.id == COLLECTION_USER_ID
  end

  def require_user!
    return if current_user
    redirect_to root_path, flash: { error: 'You are not worthy!' }
  end

  def require_api_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end
