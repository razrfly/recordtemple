class RecordsController < ApplicationController
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.page(params[:page])

    #@artists = Artist.where('name IN (?)', @search.result.map(&:cached_artist).uniq!)
    #@labels = Label.where('name IN (?)', @search.result.map(&:cached_label).uniq!)
  end

  def show
  end

  def new
    @record = Record.new
    set_record if params[:id]
  end

  def edit
  end

  def create
    @record = Record.new(record_params)

    if @record.save
      redirect_to edit_record_path(@record), notice: 'Please verify all the details and music or photos!'
    else
      render :action => "new"
    end
  end

  def update
    if @record.update_attributes(record_params)
      redirect_to @record, notice: 'Record was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @record.destroy
  end

  private
    def sort_column
      params[:sort] ||= "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    # FIX ME
    def record_params
      params.require(:price).permit()
    end

end
