# frozen_string_literal: true

# Form component helpers adapted from Tailwind Plus Catalyst UI Kit
# with olive theme from Oatmeal
module FormComponentHelper
  # Base input styles (olive-themed version of Catalyst)
  INPUT_BASE_CLASSES = [
    "block w-full rounded-lg px-3 py-2 text-base/6 sm:text-sm/6",
    "bg-white dark:bg-white/5",
    "border border-olive-300 dark:border-white/10",
    "text-olive-950 dark:text-white placeholder:text-olive-400 dark:placeholder:text-olive-500",
    "shadow-sm",
    "focus:outline-none focus:ring-2 focus:ring-olive-500 focus:border-olive-500",
    "disabled:bg-olive-50 disabled:text-olive-500 disabled:cursor-not-allowed dark:disabled:bg-white/5"
  ].join(" ").freeze

  # Error state classes
  INPUT_ERROR_CLASSES = "border-red-500 focus:ring-red-500 focus:border-red-500".freeze

  # Label styles
  LABEL_BASE_CLASSES = "block text-sm/6 font-medium text-olive-950 dark:text-white".freeze

  # Description/hint text styles
  DESCRIPTION_CLASSES = "mt-1 text-sm text-olive-500 dark:text-olive-400".freeze

  # Error message styles
  ERROR_CLASSES = "mt-1 text-sm text-red-600 dark:text-red-500".freeze

  # Render a styled text input field with label and error handling
  #
  # @param form [ActionView::Helpers::FormBuilder] Form builder
  # @param attribute [Symbol] Model attribute name
  # @param label [String] Label text (defaults to humanized attribute)
  # @param hint [String] Help text below input
  # @param options [Hash] Additional options for text_field
  #
  # @example
  #   <%= form_input f, :email, type: :email %>
  #   <%= form_input f, :password, type: :password, hint: "Minimum 8 characters" %>
  #
  def form_input(form, attribute, label: nil, hint: nil, **options)
    object = form.object
    has_error = object&.errors&.[](attribute)&.any?

    type = options.delete(:type) || :text
    input_classes = [INPUT_BASE_CLASSES, options.delete(:class)]
    input_classes << INPUT_ERROR_CLASSES if has_error

    render_form_field(form, attribute, label: label, hint: hint, has_error: has_error) do
      form.send("#{type}_field", attribute, class: input_classes.compact.join(" "), **options)
    end
  end

  # Render a styled textarea with label and error handling
  #
  # @example
  #   <%= form_textarea f, :description, rows: 4 %>
  #
  def form_textarea(form, attribute, label: nil, hint: nil, rows: 3, **options)
    object = form.object
    has_error = object&.errors&.[](attribute)&.any?

    textarea_classes = [INPUT_BASE_CLASSES, "resize-y", options.delete(:class)]
    textarea_classes << INPUT_ERROR_CLASSES if has_error

    render_form_field(form, attribute, label: label, hint: hint, has_error: has_error) do
      form.text_area(attribute, rows: rows, class: textarea_classes.compact.join(" "), **options)
    end
  end

  # Render a styled select dropdown
  #
  # @example
  #   <%= form_select f, :category, Category.all.pluck(:name, :id) %>
  #   <%= form_select f, :condition, [["Mint", "mint"], ["Good", "good"], ["Fair", "fair"]] %>
  #
  def form_select(form, attribute, choices, label: nil, hint: nil, include_blank: nil, **options)
    object = form.object
    has_error = object&.errors&.[](attribute)&.any?

    select_classes = [
      INPUT_BASE_CLASSES,
      "pr-10 appearance-none bg-no-repeat bg-right",
      options.delete(:class)
    ]
    select_classes << INPUT_ERROR_CLASSES if has_error

    render_form_field(form, attribute, label: label, hint: hint, has_error: has_error) do
      content_tag(:div, class: "relative") do
        form.select(
          attribute,
          choices,
          { include_blank: include_blank },
          class: select_classes.compact.join(" "),
          **options
        ) + select_chevron_icon
      end
    end
  end

  # Render a styled checkbox with label
  #
  # @example
  #   <%= form_checkbox f, :terms, label: "I agree to the terms" %>
  #
  def form_checkbox(form, attribute, label: nil, **options)
    checkbox_classes = [
      "size-4 rounded border-olive-300 text-olive-600",
      "focus:ring-2 focus:ring-olive-500 focus:ring-offset-0",
      "dark:border-white/10 dark:bg-white/5",
      options.delete(:class)
    ].compact.join(" ")

    label_text = label || attribute.to_s.humanize

    content_tag(:div, class: "flex items-center gap-3") do
      form.check_box(attribute, class: checkbox_classes, **options) +
        form.label(attribute, label_text, class: "text-sm text-olive-700 dark:text-olive-300")
    end
  end

  # Render a styled radio button group
  #
  # @example
  #   <%= form_radio_group f, :condition, [["Mint", "mint"], ["Good", "good"]] %>
  #
  def form_radio_group(form, attribute, choices, label: nil, **options)
    content_tag(:fieldset, class: "space-y-3") do
      legend = label ? content_tag(:legend, label, class: LABEL_BASE_CLASSES + " mb-3") : "".html_safe
      radios = choices.map do |(choice_label, choice_value)|
        content_tag(:div, class: "flex items-center gap-3") do
          form.radio_button(
            attribute,
            choice_value,
            class: "size-4 border-olive-300 text-olive-600 focus:ring-olive-500 dark:border-white/10"
          ) +
            form.label("#{attribute}_#{choice_value}", choice_label, class: "text-sm text-olive-700 dark:text-olive-300")
        end
      end.join.html_safe
      legend + radios
    end
  end

  # Render a form submit button
  #
  # @example
  #   <%= form_submit f, "Save Record" %>
  #   <%= form_submit f, "Delete", variant: :danger %>
  #
  def form_submit(form, text = "Submit", variant: :primary, size: :lg, **options)
    ui_button(text, variant: variant, size: size, type: "submit", **options)
  end

  private

  def render_form_field(form, attribute, label: nil, hint: nil, has_error: false)
    label_text = label || attribute.to_s.humanize

    content_tag(:div, class: "space-y-1") do
      label_tag = form.label(attribute, label_text, class: LABEL_BASE_CLASSES)
      input_tag = yield
      hint_tag = hint ? content_tag(:p, hint, class: DESCRIPTION_CLASSES) : "".html_safe
      error_tag = if has_error
        content_tag(:p, form.object.errors[attribute].first, class: ERROR_CLASSES)
      else
        "".html_safe
      end

      label_tag + input_tag + hint_tag + error_tag
    end
  end

  def select_chevron_icon
    content_tag(
      :span,
      class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3"
    ) do
      content_tag(
        :svg,
        class: "size-4 text-olive-400",
        viewBox: "0 0 16 16",
        fill: "none",
        "aria-hidden": "true"
      ) do
        content_tag(:path, nil, d: "M5.75 10.75L8 13L10.25 10.75", stroke: "currentColor", "stroke-width": "1.5", "stroke-linecap": "round", "stroke-linejoin": "round") +
          content_tag(:path, nil, d: "M10.25 5.25L8 3L5.75 5.25", stroke: "currentColor", "stroke-width": "1.5", "stroke-linecap": "round", "stroke-linejoin": "round")
      end
    end
  end
end
