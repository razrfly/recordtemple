module Api
  class LabelsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      sanitized = ActiveRecord::Base.sanitize_sql_like(query)

      labels = Label
        .left_joins(:records)
        .where("labels.name ILIKE ?", "%#{sanitized}%")
        .group("labels.id")
        .order(
          Arel.sql("CASE " \
            "WHEN labels.name ILIKE #{Label.connection.quote(sanitized)} THEN 0 " \
            "WHEN labels.name ILIKE #{Label.connection.quote("#{sanitized}%")} THEN 1 " \
            "ELSE 2 END"),
          Arel.sql("LENGTH(labels.name)"),
          :name
        )
        .limit(10)
        .select("labels.id, labels.name, COUNT(records.id) AS record_count")

      render json: labels.map { |l|
        { id: l.id, name: l.name, count: l.record_count }
      }
    end

    def create
      label = Label.find_or_create_by!(name: params[:name].to_s.strip)
      render json: { id: label.id, name: label.name }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
