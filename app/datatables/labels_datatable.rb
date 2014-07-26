class LabelsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Label.count,
      iTotalDisplayRecords: labels.total_entries,
      aaData: data
    }
  end

private

  def data
    labels.map do |label|
      [
        ERB::Util.h(label.name),
        ERB::Util.h(label.freebase_id),
        buttons(label)
      ]
    end
  end

  def buttons(label)
    [
      link_to('<i class="fa fa-eye fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.admin_label_path(label), :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip'}, :title => "SHOW"),
      link_to('<i class="fa fa-pencil fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.edit_admin_label_path(label), :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip'}, :title => "EDIT"),
      link_to('<i class="fa fa-times fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.admin_label_path(label), :method => :delete, :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip'}, :title => "DELETE", :confirm => "Are you sure?")
    ].join
  end

  def labels 
    @labels ||= fetch_labels
  end

  def fetch_labels
    labels = Label.order("#{sort_column} #{sort_direction}")
    labels = labels.page(page).per_page(per_page)
    if params[:sSearch].present?
      labels = labels.where("name ILIKE :search", search: "%#{params[:sSearch]}%")
    end
    labels
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
