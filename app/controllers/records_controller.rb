class RecordsController < ApplicationController
  include SearchQueryHelper
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :set_price, only: [:new, :create]
  before_action :set_user, only: [:index, :show]
  before_action :set_record, only: [:show, :edit, :update, :destroy]

  def index
    @q =
      if @user
        Record.where(user_id: @user.id).ransack(query_params)
      else
        Record.ransack(query_params)
      end

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
    @last_search_query = session[:last_search_query]
  end

  def edit
    authorize @record
  end

  def update
    if @record.update_attributes(record_params)
      redirect_to @record, notice: "Record was updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @record.destroy

    redirect_to records_path, notice: "Record was successfully deleted."
  end

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['photos_id_not_null', 'songs_id_not_null'].include?(k) && v == '0'
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(@record)
  end

  def set_record
    @record = Record.find(params[:id])
  end

  def set_price
    @price = Price.includes(
      :artist, :label, :record_format
      ).find(params[:price_id])
  end

  def set_user
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    end
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
