class LabelsController < ApplicationController
  include Pagy::Backend

  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  COLLECTION_USER_ID = 1

  def index
    add_breadcrumb("Labels")

    # Base query for all labels with records
    base_labels = Label.joins(:records)
                       .where(records: { user_id: COLLECTION_USER_ID })
                       .group("labels.id")
                       .select("labels.*, COUNT(records.id) as records_count")

    # Discovery curation collections for tabs
    @popular_labels = Label.most_collected(COLLECTION_USER_ID, 12)
    @recent_labels = Label.recently_added(COLLECTION_USER_ID, 12)
    @hidden_gem_labels = Label.hidden_gems(COLLECTION_USER_ID, 12)

    # All labels for browsing, optionally filtered by letter
    @current_letter = params[:letter]&.upcase
    labels_query = base_labels.order("labels.name ASC")

    if @current_letter.present?
      if @current_letter == "#"
        # Non-alphabetic (numbers, symbols)
        labels_query = labels_query.where("labels.name !~* '^[A-Za-z]'")
      else
        labels_query = labels_query.where("labels.name ILIKE ?", "#{@current_letter}%")
      end
    end

    @pagy, @labels = pagy(labels_query, items: 30)
    @total_count = base_labels.length

    # Get available letters for A-Z navigation
    @available_letters = Label.joins(:records)
                              .where(records: { user_id: COLLECTION_USER_ID })
                              .distinct
                              .pluck(Arel.sql("UPPER(LEFT(labels.name, 1))"))
                              .sort
  end

  def random
    # Get a random label that has records in the collection
    random_label = Label.joins(:records)
                        .where(records: { user_id: COLLECTION_USER_ID })
                        .order(Arel.sql("RANDOM()"))
                        .first

    if random_label
      redirect_to label_path(random_label)
    else
      redirect_to labels_path, alert: "No labels found in the collection."
    end
  end

  def show
    @label = Label.friendly.find(params[:id])

    add_breadcrumb("Labels", labels_path)
    add_breadcrumb(@label.name)

    # Get records for this label (scoped to user's collection)
    @q = records_scope.ransack(params[:q])
    @q.sorts = "created_at desc" if @q.sorts.empty?

    records = @q.result(distinct: true)
                .includes(:artist, :label, :genre, :record_format, :price)

    @pagy, @records = pagy(records)
    @total_count = records_scope.count
    @filtered_count = @q.result(distinct: true).count

    # Stats for the hero section
    @artists_count = records_scope.distinct.count(:artist_id)
    @genres = records_scope.joins(:genre)
                           .group("genres.name")
                           .order(Arel.sql("COUNT(*) DESC"))
                           .limit(3)
                           .pluck(Arel.sql("genres.name"))
  end

  private

  def records_scope
    Record.where(user_id: COLLECTION_USER_ID, label_id: @label.id)
  end
end
