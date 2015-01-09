class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  private
    def set_record
      @record = params[:record_id].nil? params[:id] : params[:record_id]
    end
end
