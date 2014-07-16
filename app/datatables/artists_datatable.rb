class ArtistsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Artist.count,
      iTotalDisplayRecords: artists.total_entries,
      aaData: data
    }
  end

private

  def data
    artists.map do |artist|
      [
        ERB::Util.h(artist.name),
        ERB::Util.h(artist.freebase_id),
        buttons(artist)
      ]
    end
  end

  def buttons(artist)
    [
      link_to('<i class="fa fa-eye fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.admin_artist_path(artist), :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip'}, :title => "SHOW"),
      link_to('<i class="fa fa-pencil fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.edit_admin_artist_path(artist), :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip'}, :title => "EDIT"),
      link_to('<i class="fa fa-times fa-lg"></i>'.html_safe, Rails.application.routes.url_helpers.admin_artist_path(artist), :method => :delete, :class => 'info-tooltip dynamic-button', :data => {:toggle => 'tooltip', :confirm => "Are you sure?"}, :title => "DELETE")
    ].join
  end

  def artists 
    @artists ||= fetch_artists
  end

  def fetch_artists
    artists = Artist.order("#{sort_column} #{sort_direction}")
    artists = artists.page(page).per_page(per_page)
    if params[:sSearch].present?
      artists = artists.where("name ILIKE :search", search: "%#{params[:sSearch]}%")
    end
    artists
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
