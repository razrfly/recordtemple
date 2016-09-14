class RecordsController < ApplicationController

  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_price, only: [:new, :create]

  def index
    @q = Record.where(user_id: 1).ransack(query_params)
    @result = @q.result.
      includes(:artist, :genre, :label, :price, :record_format, :songs).
      order("artists.name").
      uniq

    respond_to do |format|
      format.html do
        @records = @result.page(params[:page])
      end
      format.csv { send_data @result.to_csv }
    end
  end

  def new
    @record = @price.records.build
  end

  def create
    @record = @price.records.build(
      record_params.merge({
        artist: @price.artist,
        label: @price.label,
        record_format: @price.record_format,
        user: current_user })
      )

    if @record.save
      redirect_to @price, notice: "Record was created successfully."
    else
      render :new
    end
  end

  def show
    @record = Record.
      includes(:artist, :genre, :label, :price, :record_format, :songs).
      find(params[:id])
  end

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['photos_id_not_null', 'songs_id_not_null'].include?(k) && v == '0'
    end
  end

  def set_price
    @price = Price.includes(:artist, :label, :record_format).
      find(params[:price_id])
  end

  def record_params
    params.require(:record).permit(
      :identifier_id,
      :condition,
      :comment,
      :value,
      :genre_id,
      :price_id,
      :artist_id,
      :label_id,
      :user_id,
      :record_format_id,
      photos_attributes: [
        :id,
        :image,
        :_destroy
        ],
      songs_attributes: [
        :id,
        :audio,
        :title,
        :_destroy
        ]
      )
  end
end
