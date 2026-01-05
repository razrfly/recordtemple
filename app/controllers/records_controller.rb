class RecordsController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  # This is a single-user collection display
  COLLECTION_USER_ID = 1

  def index
    add_breadcrumb("Collection")

    @q = base_scope.ransack(params[:q])

    # Apply Ransack native sorting with default (Popular = highest popularity_score first)
    @q.sorts = "popularity_score desc" if @q.sorts.empty?

    # PostgreSQL requires ORDER BY columns in SELECT for DISTINCT
    # Skip distinct when sorting by associations to avoid this conflict
    use_distinct = !sorting_by_association?

    records = @q.result(distinct: use_distinct)
                .includes(:artist, :label, :genre, :record_format, :price)

    # Apply media filters
    records = records.has_images if params[:has_images] == "1"
    records = records.has_songs if params[:has_audio] == "1"

    @pagy, @records = pagy(records)
    @total_count = base_scope.count
    @filtered_count = @q.result(distinct: use_distinct).count

    # Load filter options with counts (scoped to user's collection)
    load_filter_options
  end

  def show
    @record = base_scope.includes(:artist, :label, :genre, :record_format, :price)
                        .find(params[:id])

    # Build contextual breadcrumbs based on navigation source
    build_record_breadcrumbs(@record)

    # Load related records
    @artist_records = base_scope.where(artist_id: @record.artist_id)
                                .where.not(id: @record.id)
                                .includes(:artist, :label, :genre, :record_format)
                                .limit(5)

    @label_records = base_scope.where(label_id: @record.label_id)
                               .where.not(id: @record.id)
                               .includes(:artist, :label, :genre, :record_format)
                               .limit(5)
  end

  private

  def base_scope
    Record.where(user_id: COLLECTION_USER_ID)
  end

  # Build contextual breadcrumbs based on how user navigated to this record
  # Uses multiple detection strategies: URL params, session, referer
  def build_record_breadcrumbs(record)
    context = breadcrumb_context_for(record)

    case context
    when :artist
      # Use context_artist helper which checks params and session
      artist = context_artist || record.artist
      if artist
        add_breadcrumb("Artists", artists_path)
        add_breadcrumb(artist.name, artist_path(artist))
      else
        add_breadcrumb("Collection", records_path)
      end
    when :label
      # Use context_label helper which checks params and session
      label = context_label || record.label
      if label
        add_breadcrumb("Labels", labels_path)
        add_breadcrumb(label.name, label_path(label))
      else
        add_breadcrumb("Collection", records_path)
      end
    else
      add_breadcrumb("Collection", records_path)
    end

    add_breadcrumb(record.title.presence || "Untitled")
  end

  def sorting_by_association?
    sort_param = params.dig(:q, :s).to_s
    sort_param.match?(/^(artist|label|genre|record_format)_/)
  end

  def load_filter_options
    # Get genre counts
    @genres = Genre.joins(:records)
                   .where(records: { user_id: COLLECTION_USER_ID })
                   .group("genres.id", "genres.name")
                   .order(Arel.sql("COUNT(records.id) DESC"))
                   .limit(20)
                   .pluck(Arel.sql("genres.id"), Arel.sql("genres.name"), Arel.sql("COUNT(records.id)"))
                   .map { |id, name, count| { id: id, name: name, count: count } }

    # Get format counts
    @formats = RecordFormat.joins(:records)
                           .where(records: { user_id: COLLECTION_USER_ID })
                           .group("record_formats.id", "record_formats.name")
                           .order(Arel.sql("COUNT(records.id) DESC"))
                           .pluck(Arel.sql("record_formats.id"), Arel.sql("record_formats.name"), Arel.sql("COUNT(records.id)"))
                           .map { |id, name, count| { id: id, name: name, count: count } }

    # Get condition counts - use a simpler approach
    @conditions = base_scope.group(:condition)
                            .count
                            .sort_by { |_, count| -count }
                            .map { |condition, count| { value: condition, count: count } }

    # Get media counts
    @has_images_count = base_scope.has_images.count
    @has_audio_count = base_scope.has_songs.count
  end
end
