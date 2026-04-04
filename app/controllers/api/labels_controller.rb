module Api
  class LabelsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      labels = Label
        .where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
        .order(:name)
        .limit(10)

      render json: labels.map { |l|
        { id: l.id, name: l.name }
      }
    end
  end
end
