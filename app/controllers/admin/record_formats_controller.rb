class Admin::RecordFormatsController < Admin::AdminController
  before_action :set_record_format, :only => [:show, :edit, :update, :destroy]

  def index
    @record_formats = RecordFormat.all.includes(:record_type)
  end

  def show
  end

  def new
    @record_format = RecordFormat.new
  end

  def edit
  end

  def create
    @record_format = RecordFormat.new(record_format_params)

    if @record_format.save
      redirect_to admin_record_formats_path, :notice => "Record format was successfully created."
    else
      render :new
    end
  end

  def update
    if @record_format.update_attributes(record_format_params)
      redirect_to admin_record_formats_path, :notice => "Record format was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @record_format.destroy
    redirect_to admin_record_formats_path, :notice => "Record format was successfully deleted."
  end

  private
    def set_record_format
      @record_format = RecordFormat.includes(:record_type).find(params[:id])
    end

    def record_format_params
      params.require(:record_format).permit(:name, :record_type_id)
    end
end
