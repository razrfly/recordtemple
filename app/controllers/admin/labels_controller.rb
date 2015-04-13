class Admin::LabelsController < Admin::AdminController
  authorize_resource
  before_action :set_label, :only => [:show, :edit, :update, :destroy]

  def index
    @search = Label.ransack(params[:q])
    @labels = @search.result.page(params[:page])
    respond_to do |format|
      format.html
      format.json {
        render json: @labels.to_json(:only => [:name, :id]) }
    end
  end

  def show
    @prices = @label.prices.page(params[:prices_page])
    @records = @label.records.where(user: current_user).page(params[:records_page])
  end

  def new
    @label = Label.new
  end

  def edit
  end

  def create
    @label = Label.new(artist_params)

    if @label.save
      redirect_to admin_labels_path, :notice => "Label was successfully created."
    else
      render :new
    end
  end

  def update
    if @label.update_attributes(artist_params)
      redirect_to admin_labels_path, :notice => "Label was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @label.destroy
    redirect_to admin_labels_path, :notice => "Label was successfully deleted."
  end

  private
    def set_label
      @label = Label.find(params[:id])
    end

    def artist_params
      params.require(:label).permit(:name, :freebase_id)
    end
end
