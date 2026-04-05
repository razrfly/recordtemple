module Api
  class LabelsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      labels = Label
        .left_joins(:records)
        .where("labels.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
        .group("labels.id")
        .order(:name)
        .limit(10)
        .select("labels.id, labels.name, COUNT(records.id) AS record_count")

      render json: labels.map { |l|
        { id: l.id, name: l.name, count: l.record_count }
      }
    end
  end
end
