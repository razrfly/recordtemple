# frozen_string_literal: true

# Provides breadcrumb navigation functionality to controllers.
#
# Include in ApplicationController to make available everywhere:
#   include Breadcrumbable
#
# Usage in controllers:
#   class RecordsController < ApplicationController
#     def show
#       add_breadcrumb("Collection", records_path)
#       add_breadcrumb(@record.title)
#     end
#   end
#
# Usage in views:
#   <%= render "shared/breadcrumbs" %>
#
# Breadcrumbs are objective - they reflect the record's data,
# not how the user navigated to the page.
#
module Breadcrumbable
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  # Returns the array of breadcrumb items for the current request
  def breadcrumbs
    @breadcrumbs ||= []
  end

  # Add a breadcrumb to the trail
  #
  # @param name [String] Display text for the breadcrumb
  # @param path [String, nil] URL path (nil for current page)
  # @param icon [String, nil] Optional icon name
  #
  # Examples:
  #   add_breadcrumb("Artists", artists_path)
  #   add_breadcrumb(@artist.name)  # Current page, no link
  #   add_breadcrumb("Home", root_path, icon: "home")
  #
  def add_breadcrumb(name, path = nil, icon: nil)
    breadcrumbs << Breadcrumb.new(name, path, icon: icon)
  end

  # Clear all breadcrumbs (useful for resetting in specific actions)
  def clear_breadcrumbs
    @breadcrumbs = []
  end
end
