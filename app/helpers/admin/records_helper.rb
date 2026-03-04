# frozen_string_literal: true

module Admin
  module RecordsHelper
    def value_sort_link(column, label)
      current_sort = params[:sort] || "best_value"
      current_dir = params[:direction] || "desc"
      new_dir = (current_sort == column && current_dir == "desc") ? "asc" : "desc"
      arrow = if current_sort == column
                current_dir == "desc" ? " &#9660;" : " &#9650;"
              else
                ""
              end

      link_to "#{label}#{arrow}".html_safe,
        admin_records_path(request.query_parameters.merge(sort: column, direction: new_dir).except("page")),
        data: { turbo_frame: "admin_records_list" },
        class: "group inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-wide #{current_sort == column ? 'text-olive-950' : 'text-olive-500 hover:text-olive-700'}"
    end
  end
end
