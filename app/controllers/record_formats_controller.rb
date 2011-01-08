class RecordFormatsController < ApplicationController
  def index
    @record_formats = RecordFormat.all
  end
  
  def show
    @record_format = RecordFormat.find(params[:id])
  end
  
  def new
    @record_format = RecordFormat.new
  end
  
  def create
    @record_format = RecordFormat.new(params[:record_format])
    if @record_format.save
      flash[:notice] = "Successfully created record format."
      redirect_to @record_format
    else
      render :action => 'new'
    end
  end
  
  def edit
    @record_format = RecordFormat.find(params[:id])
  end
  
  def update
    @record_format = RecordFormat.find(params[:id])
    if @record_format.update_attributes(params[:record_format])
      flash[:notice] = "Successfully updated record format."
      redirect_to @record_format
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @record_format = RecordFormat.find(params[:id])
    @record_format.destroy
    flash[:notice] = "Successfully destroyed record format."
    redirect_to record_formats_url
  end
end
