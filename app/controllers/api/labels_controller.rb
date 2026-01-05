module Api
  class LabelsController < ApplicationController
    COLLECTION_USER_ID = 1

    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      labels = Label
        .joins(:records)
        .where(records: { user_id: COLLECTION_USER_ID })
        .where("labels.name ILIKE ?", "%#{sanitize_sql_like(query)}%")
        .group("labels.id")
        .order(Arel.sql("COUNT(records.id) DESC"))
        .limit(10)
        .select("labels.id, labels.name, COUNT(records.id) AS record_count")

      render json: labels.map { |l|
        { id: l.id, name: l.name, count: l.record_count }
      }
    end

    private

    def sanitize_sql_like(string)
      string.gsub(/[\\%_]/) { |x| "\\#{x}" }
    end
  end
end
