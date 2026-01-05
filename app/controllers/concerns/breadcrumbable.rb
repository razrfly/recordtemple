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
# Context Detection:
#   Navigation context is determined solely by URL parameters:
#   - from=artist&artist_id=123 → shows artist trail
#   - from=label&label_id=456 → shows label trail
#   - No params → shows collection trail
#
#   This keeps behavior predictable and URLs shareable.
#
module Breadcrumbable
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs, :navigation_context
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

  # Returns the current navigation context based on URL params
  def navigation_context
    @navigation_context ||= detect_navigation_context
  end

  # Determine breadcrumb context for a record based on URL params
  #
  # @param record [Record] The record being viewed
  # @return [Symbol] The context type (:artist, :label, or :collection)
  #
  def breadcrumb_context_for(record)
    context = detect_navigation_context

    # Validate that the context matches the record's associations
    case context
    when :artist
      # Verify the artist_id in params matches record's artist
      if params[:artist_id].present? && record.artist_id.to_s == params[:artist_id].to_s
        :artist
      else
        :collection
      end
    when :label
      # Verify the label_id in params matches record's label
      if params[:label_id].present? && record.label_id.to_s == params[:label_id].to_s
        :label
      else
        :collection
      end
    else
      :collection
    end
  end

  # Get the artist from URL params
  def context_artist
    return @context_artist if defined?(@context_artist)

    @context_artist = params[:artist_id].present? ? Artist.find_by(id: params[:artist_id]) : nil
  end

  # Get the label from URL params
  def context_label
    return @context_label if defined?(@context_label)

    @context_label = params[:label_id].present? ? Label.find_by(id: params[:label_id]) : nil
  end

  private

  # Detect navigation context from URL parameters only
  # This keeps behavior predictable and URLs shareable
  def detect_navigation_context
    return :artist if params[:from] == "artist" && params[:artist_id].present?
    return :label if params[:from] == "label" && params[:label_id].present?

    :collection
  end
end
