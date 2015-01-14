class Admin::RecordsController < Admin::AdminController
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  before_action :set_media, only: :index

  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.page(params[:page])
    # @records = @search.result.limit(50)
    @record_formats = RecordFormat.all.map{|rf| rf if rf.records.size>0 }.compact
    @genres = Genre.all.map{|genre| genre if genre.records.size>0 }.compact
    @conditions = Hash[Record.conditions.map{ |k, v| [Record.transform_condition(k), v]}]
    # media
    @records = @records.map{|r| r if r.photo}.compact if @photo
    @records = @records.map{|r| r if r.songs.size>0}.compact if @audio
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
      redirect_to admin_edit_record_path(@record), notice: 'Please verify all the details and music or photos!'
    else
      render :action => "new"
    end
  end

  def update
    if @record.update_attributes(record_params)
      redirect_to [:admin, @record], notice: 'Record was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @record.destroy
  end

  private

    # def sort_column
    #   params[:sort] ||= "updated_at"
    # end

    # def sort_direction
    #   %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    # end

    def set_media
      @photo = params[:photo]=='present' ? true : false
      @audio = params[:audio]=='present' ? true : false
    end

    def set_record
      @record = Record.find(params[:id])
    end

    def record_params
      params.require(:price).permit()
    end
end
