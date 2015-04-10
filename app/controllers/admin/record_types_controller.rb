class Admin::RecordTypesController < Admin::AdminController
  authorize_resource
  before_action :set_record_type, :only => [:show, :edit, :update, :destroy]

  def index
    @record_types = RecordType.all
  end

  def show
  end

  def new
    @record_type = RecordType.new
  end

  def edit
  end

  def create
    @record_type = RecordType.new(record_type_params)

    if @record_type.save
      redirect_to admin_record_types_path, :notice => "Record type was successfully created."
    else
      render :new
    end
  end

  def update
    if @record_type.update_attributes(record_type_params)
      redirect_to admin_record_types_path, :notice => "Record type was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @record_type.destroy
    redirect_to admin_record_types_path, :notice => "Record type was successfully deleted."
  end

  private
    def set_record_type
      @record_type = RecordType.find(params[:id])
    end

    def record_type_params
      params.require(:record_type).permit(:name)
    end
end
