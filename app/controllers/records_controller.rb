class RecordsController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  # This is a single-user collection display
  COLLECTION_USER_ID = 1

  def index
    add_breadcrumb("Collection")

    # Start with base scope
    scope = base_scope

    # Apply wide-net search if search query present (pg_search)
    if params[:search].present?
      scope = scope.wide_search(params[:search])
      @search_query = params[:search]
    end

    # Apply Ransack filters on top of search results
    @q = scope.ransack(params[:q])

    # Apply Ransack native sorting with default (Popular = highest popularity_score first)
    # Skip default sort when using wide_search as it has its own relevance ranking
    @q.sorts = "popularity_score desc" if @q.sorts.empty? && params[:search].blank?

    # PostgreSQL requires ORDER BY columns in SELECT for DISTINCT
    # Skip distinct when sorting by associations to avoid this conflict
    # Also skip during pg_search as it adds ranking columns to ORDER BY
    # Note: belongs_to associations (artist, label, genre, etc.) don't produce
    # duplicate records, so skipping DISTINCT is safe here
    use_distinct = !sorting_by_association? && params[:search].blank?

    records = @q.result(distinct: use_distinct)
                .includes(:artist, :label, :genre, :record_format, :price)
                .with_attached_images
                .with_attached_songs

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
                        .with_attached_images
                        .with_attached_songs
                        .find(params[:id])

    # Build objective breadcrumbs based on record data
    build_record_breadcrumbs(@record)

    # Load related records
    @artist_records = base_scope.where(artist_id: @record.artist_id)
                                .where.not(id: @record.id)
                                .includes(:artist, :label, :genre, :record_format)
                                .with_attached_images
                                .with_attached_songs
                                .limit(5)

    @label_records = base_scope.where(label_id: @record.label_id)
                               .where.not(id: @record.id)
                               .includes(:artist, :label, :genre, :record_format)
                               .with_attached_images
                               .with_attached_songs
                               .limit(5)
  end

  private

  def base_scope
    Record.where(user_id: COLLECTION_USER_ID)
  end

  # Build objective breadcrumbs based on record's data
  # Hierarchy: Collection > Label > Artist > Title
  def build_record_breadcrumbs(record)
    add_breadcrumb("Collection", records_path)

    if record.label.present?
      add_breadcrumb(record.label.name, label_path(record.label))
    end

    if record.artist.present?
      add_breadcrumb(record.artist.name, artist_path(record.artist))
    end

    add_breadcrumb(record.breadcrumb_title.presence || "Untitled")
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
