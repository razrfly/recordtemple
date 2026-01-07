# frozen_string_literal: true

# Centralized variant definitions for consistent image processing across the app.
# Using WebP format for 25-35% smaller file sizes with equivalent quality.
#
# Usage in views:
#   image.variant(ImageVariants::CARD)
#   image.variant(ImageVariants::THUMBNAIL)
#
module ImageVariants
  WEBP_DEFAULTS = { format: :webp, saver: { strip: true } }.freeze

  # Record cards, gem cards, shuffle cards, quick view (400x400)
  CARD = { resize_to_fill: [400, 400], **WEBP_DEFAULTS, saver: { strip: true, quality: 80 } }.freeze

  # Labels, genres, artists show pages (320x320)
  COVER = { resize_to_fill: [320, 320], **WEBP_DEFAULTS, saver: { strip: true, quality: 80 } }.freeze

  # Wall covers, discovery cards small (200x200)
  THUMBNAIL = { resize_to_fill: [200, 200], **WEBP_DEFAULTS, saver: { strip: true, quality: 75 } }.freeze

  # Tall discovery cards (200x400)
  TALL = { resize_to_fill: [200, 400], **WEBP_DEFAULTS, saver: { strip: true, quality: 75 } }.freeze

  # Show page thumbnails (160x160)
  THUMB_SMALL = { resize_to_fill: [160, 160], **WEBP_DEFAULTS, saver: { strip: true, quality: 75 } }.freeze

  # Tiny thumbnails (96x96)
  THUMB_TINY = { resize_to_fill: [96, 96], **WEBP_DEFAULTS, saver: { strip: true, quality: 70 } }.freeze

  # Show page main image (600x600)
  MAIN = { resize_to_fill: [600, 600], **WEBP_DEFAULTS, saver: { strip: true, quality: 85 } }.freeze

  # Lightbox/full size (1200x1200 max)
  FULL = { resize_to_limit: [1200, 1200], **WEBP_DEFAULTS, saver: { strip: true, quality: 90 } }.freeze
end
