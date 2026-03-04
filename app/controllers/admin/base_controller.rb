# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "Admin access required"
      end
    end
  end
end
