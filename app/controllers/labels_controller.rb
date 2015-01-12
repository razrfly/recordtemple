class LabelsController < ApplicationController
  before_action :set_label, :only => [:show, :edit, :update]

  def index
    respond_to do |format|
      format.html
      format.json { render json: LabelsDatatable.new(view_context) }
    end
  end

  def show
  end

  def edit
  end

  def update
    if @label.update_attributes(artist_params)
      redirect_to labels_path, :notice => "Label was successfully updated."
    else
      render :edit
    end
  end

  private
    def set_label
      @label = Label.find(params[:id])
    end

    def artist_params
      params.require(:label).permit(:name, :freebase_id)
    end
end
