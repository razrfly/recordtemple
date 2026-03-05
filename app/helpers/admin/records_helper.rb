# frozen_string_literal: true

module Admin
  module RecordsHelper
    def confidence_reason(record)
      guide    = record[:adjusted_value].to_f
      personal = record[:personal_value].to_f
      discogs  = record[:discogs_lowest_price].to_f
      has_guide    = record[:price_high].to_i > 0
      has_personal = personal > 0
      has_discogs  = discogs > 0

      fmt = ->(v) { "$#{number_with_delimiter(v.round(0))}" }

      discogs_corr = has_discogs && (
        (has_guide && guide > 0 && (discogs / guide).between?(1.0 / 3.0, 3.0)) ||
        (has_personal && personal > 0 && (discogs / personal).between?(1.0 / 3.0, 3.0))
      )

      if has_guide && has_personal
        ratio = guide / personal
        if    ratio >= 0.5 && ratio <= 2.0  then "Guide #{fmt.(guide)} and personal #{fmt.(personal)} agree (#{ratio.round(1)}×)"
        elsif discogs_corr                   then "Discogs #{fmt.(discogs)} corroborates pricing"
        elsif ratio >= 0.2 && ratio <= 5.0  then "Guide #{fmt.(guide)} vs personal #{fmt.(personal)} — some disagreement (#{ratio.round(1)}×)"
        elsif ratio > 5.0  && ratio <= 10.0 then "Guide #{fmt.(guide)} vs personal #{fmt.(personal)} — significant gap (#{ratio.round(1)}×)"
        else                                      "Guide #{fmt.(guide)} vs personal #{fmt.(personal)} — wildly different (#{ratio.round(1)}×)"
        end
      elsif has_guide
        discogs_corr ? "Guide #{fmt.(guide)} corroborated by Discogs #{fmt.(discogs)}" : "Guide price only — set a personal value to improve confidence"
      elsif has_personal
        "Personal value #{fmt.(personal)} only — no guide price linked"
      else
        "No pricing data available"
      end
    end

    def value_sort_link(column, label)
      current_sort = params[:sort] || "best_value"
      current_dir = params[:direction] || "desc"
      new_dir = (current_sort == column && current_dir == "desc") ? "asc" : "desc"
      arrow = if current_sort == column
                current_dir == "desc" ? " ▼" : " ▲"
              else
                ""
              end

      link_to "#{label}#{arrow}",
        admin_records_path(request.query_parameters.merge(sort: column, direction: new_dir).except("page")),
        data: { turbo_frame: "admin_records_list", turbo_action: "advance" },
        class: "group inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-wide #{current_sort == column ? 'text-olive-950' : 'text-olive-500 hover:text-olive-700'}"
    end
  end
end
