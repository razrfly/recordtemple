# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
    end
  end
end
