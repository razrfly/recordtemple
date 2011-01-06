class LabelsController < ApplicationController
  def index
    @labels = Record.find(:all, 
                          :select => 'DISTINCT(label), MIN(records.id) as ID', 
                          :joins => [ :price, :photos ], 
                          :group => :label).paginate :per_page => 49, :page => params[:page]
  end

  def show
    @label = Label.find(params[:id])
    @freebase = Ken::Topic.get(@label.freebase_id) unless @label.freebase_id.blank?
  end

  def edit
    @label = Label.find(params[:id])
  end
  
  def update
    @label = Label.find(params[:id])
    if @label.update_attributes(params[:label])
      flash[:notice] = "Successfully updated label."
      redirect_to @label
    else
      render :action => 'edit'
    end
  end
end
