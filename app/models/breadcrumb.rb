# frozen_string_literal: true

# Simple PORO for representing a breadcrumb item.
# Does not require database persistence.
#
# Usage:
#   Breadcrumb.new("Artists", artists_path)
#   Breadcrumb.new("Miles Davis") # Current page, no link
#
class Breadcrumb
  attr_reader :name, :path, :icon

  def initialize(name, path = nil, icon: nil)
    @name = name
    @path = path
    @icon = icon
  end

  # Returns true if this breadcrumb should render as a clickable link
  def link?
    @path.present?
  end

  # Returns true if this is the current/final page (no link)
  def current?
    !link?
  end
end
