class RecordsController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  # This is a single-user collection display
  COLLECTION_USER_ID = 1

  before_action :require_user!, only: [:new, :create, :edit, :update, :confirm_delete, :destroy]
  before_action :require_collection_owner!, only: [:new, :create, :edit, :update, :confirm_delete, :destroy]
  before_action :set_record, only: [:edit, :update]
  before_action :set_record_for_delete, only: [:confirm_delete, :destroy]

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

    # Boost exact artist/label name matches to the top of results
    # Applied AFTER ransack.result so the custom ORDER BY isn't dropped.
    # Preserve pg_search relevance ordering as a secondary sort within each
    # CASE bucket so a strong full-text hit beats a weak trigram hit.
    if params[:search].present?
      quoted = Record.connection.quote(ActiveRecord::Base.sanitize_sql_like(params[:search]))
      existing_orders = records.order_values
      records = records.reorder(
        Arel.sql("CASE " \
          "WHEN records.cached_artist ILIKE #{quoted} THEN 0 " \
          "WHEN records.cached_label ILIKE #{quoted} THEN 1 " \
          "ELSE 2 END")
      )
      records = records.order(*existing_orders) if existing_orders.any?
      records = records.order("records.id ASC")
    end

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
    @record = base_scope.includes(:artist, :label, :genre, :record_format, :price, :discogs_release)
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

  def new
    @record = Record.new(user_id: COLLECTION_USER_ID)
    load_form_options
  end

  def create
    @record = Record.new(record_params)
    @record.user_id = COLLECTION_USER_ID

    if @record.save
      redirect_to @record, notice: "Record created successfully."
    else
      load_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_options
  end

  def update
    if @record.update(record_params)
      redirect_to @record, notice: "Record updated successfully."
    else
      load_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  # Tier B confirmation page. Tier A (no media) never reaches this — its button
  # posts DELETE directly with a turbo_confirm.
  def confirm_delete
    build_record_breadcrumbs(@record)
  end

  def destroy
    # Re-derive the tier server-side. A record can gain attachments between page
    # render and submit, and Tier A posts a plain DELETE that a client could aim
    # at a media-bearing record. Without this the friction is decorative.
    if @record.has_media? && params[:confirm] != "DELETE"
      return redirect_to confirm_delete_record_path(@record),
                         alert: "Type DELETE exactly to confirm.",
                         status: :see_other
    end

    # Captured before the destroy: #title reads song_titles off the attachments.
    title = @record.title
    counts = @record.media_counts

    @record.destroy!
    redirect_to records_path, notice: deletion_notice(title, counts), status: :see_other
  rescue ActiveRecord::InvalidForeignKey
    redirect_to confirm_delete_record_path(@record),
                alert: "Couldn't delete this record: other data still references it. Nothing was removed.",
                status: :see_other
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to confirm_delete_record_path(@record),
                alert: "Couldn't delete this record: #{e.record.errors.full_messages.to_sentence}. Nothing was removed.",
                status: :see_other
  end

  private

  def set_record
    @record = base_scope.find(params[:id])
  end

  # Eager-loads attachments so media_counts/media_bytes on the confirm page do
  # not N+1, and turns a stale tab or double submit into a redirect, not a 404.
  def set_record_for_delete
    @record = base_scope.with_attached_images.with_attached_songs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to records_path, alert: "That record no longer exists."
  end

  # Never says "and all associated data" — always enumerate what goes and what
  # stays, because the price guide entry, artist and label all survive (#384).
  def deletion_notice(title, counts)
    parts = []
    parts << helpers.pluralize(counts[:images], "image") if counts[:images].positive?
    parts << helpers.pluralize(counts[:songs], "audio file") if counts[:songs].positive?
    return %(Deleted "#{title}".) if parts.empty?

    %(Deleted "#{title}" along with #{parts.to_sentence}. The price guide entry was kept.)
  end

  def require_collection_owner!
    redirect_to records_path, alert: "Not authorized." unless collection_owner?
  end

  def record_params
    params.require(:record).permit(
      :condition, :comment,
      :artist_id, :label_id, :genre_id, :record_format_id, :price_id
    )
  end

  def load_form_options
    @conditions = Record.conditions.keys
    # Artists and Labels use autocomplete search (via /api/artists and /api/labels)
    # Genre and Format are small enough for standard dropdowns
    @genres = Genre.order(:name).pluck(:name, :id)
    @formats = RecordFormat.order(:name).pluck(:name, :id)
  end

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

    # Get type counts (joined through record_formats)
    @record_types = RecordType.joins(record_formats: :records)
                              .where(records: { user_id: COLLECTION_USER_ID })
                              .group("record_types.id", "record_types.name")
                              .order(Arel.sql("COUNT(records.id) DESC"))
                              .pluck(Arel.sql("record_types.id"), Arel.sql("record_types.name"), Arel.sql("COUNT(records.id)"))
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
