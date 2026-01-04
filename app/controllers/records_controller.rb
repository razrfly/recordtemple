class RecordsController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  # This is a single-user collection display
  COLLECTION_USER_ID = 1

  def index
    @q = base_scope.ransack(params[:q])
    records = @q.result(distinct: true)
                .includes(:artist, :label, :genre, :record_format, :price)

    # Apply sorting
    records = apply_sorting(records)

    # Apply media filters
    records = records.has_images if params[:has_images] == "1"
    records = records.has_songs if params[:has_audio] == "1"

    @pagy, @records = pagy(records)
    @total_count = base_scope.count
    @filtered_count = @q.result(distinct: true).count

    # Load filter options with counts (scoped to user's collection)
    load_filter_options
  end

  def show
    @record = base_scope.includes(:artist, :label, :genre, :record_format, :price)
                        .find(params[:id])

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

  def apply_sorting(records)
    case params[:sort]
    when "artist_asc"
      records.joins(:artist).order(Arel.sql("artists.name ASC"))
    when "artist_desc"
      records.joins(:artist).order(Arel.sql("artists.name DESC"))
    when "label_asc"
      records.joins(:label).order(Arel.sql("labels.name ASC"))
    when "label_desc"
      records.joins(:label).order(Arel.sql("labels.name DESC"))
    when "oldest"
      records.order(created_at: :asc)
    when "condition_best"
      records.order(condition: :asc)
    when "condition_worst"
      records.order(condition: :desc)
    else
      records.order(created_at: :desc) # Default: newest first
    end
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
