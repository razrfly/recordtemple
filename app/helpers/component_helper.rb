# frozen_string_literal: true

# UI Component helpers adapted from Tailwind Plus Oatmeal theme
module ComponentHelper
  # Button sizes
  BUTTON_SIZES = {
    sm: "px-2.5 py-0.5 text-xs/6",
    md: "px-3 py-1 text-sm/7",
    lg: "px-4 py-2 text-sm/7"
  }.freeze

  # Button variants with olive theme
  BUTTON_VARIANTS = {
    primary: "bg-olive-950 text-white hover:bg-olive-800 dark:bg-olive-300 dark:text-olive-950 dark:hover:bg-olive-200",
    secondary: "bg-white text-olive-950 hover:bg-olive-100 dark:bg-olive-100 dark:hover:bg-white",
    soft: "bg-olive-950/10 text-olive-950 hover:bg-olive-950/15 dark:bg-white/10 dark:text-white dark:hover:bg-white/20",
    plain: "text-olive-950 hover:bg-olive-950/10 dark:text-white dark:hover:bg-white/10",
    danger: "bg-red-600 text-white hover:bg-red-500 dark:bg-red-500 dark:hover:bg-red-400"
  }.freeze

  # Render a styled button
  #
  # @param text [String] Button text (or pass block)
  # @param variant [Symbol] :primary, :secondary, :soft, :plain, :danger
  # @param size [Symbol] :sm, :md, :lg
  # @param href [String] If provided, renders as link
  # @param disabled [Boolean] Disabled state
  # @param icon [Boolean] Include icon styles
  # @param class [String] Additional CSS classes
  # @param options [Hash] Additional HTML attributes
  #
  # @example
  #   <%= ui_button "Save", variant: :primary %>
  #   <%= ui_button "Cancel", variant: :secondary, size: :sm %>
  #   <%= ui_button "Delete", variant: :danger, data: { confirm: "Are you sure?" } %>
  #   <%= ui_button href: records_path do %>
  #     Browse Records
  #   <% end %>
  #
  def ui_button(text = nil, variant: :primary, size: :md, href: nil, disabled: false, icon: false, **options, &block)
    content = block_given? ? capture(&block) : text

    base_classes = [
      "inline-flex shrink-0 items-center justify-center gap-1 rounded-full font-medium",
      "focus:outline-none focus:ring-2 focus:ring-olive-500 focus:ring-offset-2",
      "transition-colors duration-150",
      BUTTON_SIZES[size],
      BUTTON_VARIANTS[variant]
    ]

    base_classes << "cursor-not-allowed opacity-50" if disabled
    base_classes << options.delete(:class) if options[:class]

    final_classes = base_classes.compact.join(" ")

    if href.present?
      link_to(content, href, class: final_classes, **options)
    else
      options[:type] ||= "button"
      options[:disabled] = disabled if disabled
      button_tag(content, class: final_classes, **options)
    end
  end

  # Render a link styled as button
  #
  # @example
  #   <%= ui_button_link "View Record", record_path(@record) %>
  #
  def ui_button_link(text = nil, href, **options, &block)
    ui_button(text, href: href, **options, &block)
  end

  # Badge variants
  BADGE_VARIANTS = {
    default: "bg-olive-100 text-olive-700 dark:bg-olive-800 dark:text-olive-300",
    success: "bg-green-100 text-green-700 dark:bg-green-800 dark:text-green-300",
    warning: "bg-amber-100 text-amber-700 dark:bg-amber-800 dark:text-amber-300",
    danger: "bg-red-100 text-red-700 dark:bg-red-800 dark:text-red-300",
    info: "bg-blue-100 text-blue-700 dark:bg-blue-800 dark:text-blue-300"
  }.freeze

  BADGE_SIZES = {
    sm: "px-1.5 py-0.5 text-xs",
    md: "px-2 py-0.5 text-xs",
    lg: "px-2.5 py-1 text-sm"
  }.freeze

  # Render a styled badge
  #
  # @example
  #   <%= ui_badge "New" %>
  #   <%= ui_badge "Mint", variant: :success %>
  #   <%= ui_badge record.condition, variant: condition_variant(record.condition) %>
  #
  def ui_badge(text, variant: :default, size: :md, **options)
    classes = [
      "inline-flex items-center rounded-full font-medium",
      BADGE_SIZES[size],
      BADGE_VARIANTS[variant],
      options.delete(:class)
    ].compact.join(" ")

    content_tag(:span, text, class: classes, **options)
  end

  # Card component
  #
  # @example
  #   <%= ui_card do %>
  #     <h3>Card Title</h3>
  #     <p>Card content</p>
  #   <% end %>
  #
  #   <%= ui_card padding: :lg, shadow: true do %>
  #     Content with more padding and shadow
  #   <% end %>
  #
  def ui_card(padding: :md, shadow: false, border: true, **options, &block)
    padding_classes = {
      none: "",
      sm: "p-4",
      md: "p-6",
      lg: "p-8"
    }

    classes = [
      "bg-white dark:bg-olive-900 rounded-xl",
      padding_classes[padding],
      shadow ? "shadow-lg" : nil,
      border ? "border border-olive-200 dark:border-olive-800" : nil,
      options.delete(:class)
    ].compact.join(" ")

    content_tag(:div, class: classes, **options, &block)
  end

  # Container component for consistent max-width and padding
  #
  # @example
  #   <%= ui_container do %>
  #     Page content
  #   <% end %>
  #
  def ui_container(**options, &block)
    classes = [
      "mx-auto w-full max-w-2xl px-6 md:max-w-3xl lg:max-w-7xl lg:px-10",
      options.delete(:class)
    ].compact.join(" ")

    content_tag(:div, class: classes, **options, &block)
  end

  # Section component for page sections
  #
  # @example
  #   <%= ui_section do %>
  #     Section content
  #   <% end %>
  #
  def ui_section(padding: :md, **options, &block)
    padding_classes = {
      sm: "py-8",
      md: "py-16",
      lg: "py-24"
    }

    classes = [
      padding_classes[padding],
      options.delete(:class)
    ].compact.join(" ")

    content_tag(:section, class: classes, **options, &block)
  end
end
