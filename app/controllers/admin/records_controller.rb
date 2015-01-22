class Admin::RecordsController < Admin::AdminController
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  # before_action :set_price, only: [:create, :update]
  before_action :set_media, only: :index
  before_action :set_collections, only: [:edit, :new, :create, :update]
  before_action :set_values, only: :edit

  def index
    @search = Record.ransack(params[:q])
    @records = @search.result

    @record_formats = RecordFormat.not_empty
    @genres = Genre.not_empty
    @conditions = Record.condition_collection
    # media
    @records = @records.map{|r| r if r.photo}.compact if @photo
    @records = @records.map{|r| r if r.songs.size>0}.compact if @audio
    unless @records.kind_of?(Array)
      @records = @records.page(params[:page])
    else
      @records = Kaminari.paginate_array(@records).page(params[:page])
    end
  end

  def show
  end

  def new
    @record = Record.new
  end

  def edit
  end

  def create
    @record = Record.new record_params.merge( user: current_user)#, artist: @artist, label: @label, record_format: @record_format)
    if @record.save
      redirect_to [:admin, @record], notice: 'Please verify all the details and music or photos!'
    else
      render :action => "new"
    end
  end

  def update
    if @record.update_attributes record_params#.merge( artist: @artist, label: @label, record_format: @record_format)
      redirect_to [:admin, @record], notice: 'Record was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @record.destroy
  end

  private

    # def set_price
    #   if params[:price_id]
    #     @price = Price.find(params[:price_id])
    #     @artist, @label, @record_format = @price.artist, @price.label, @price.record_format
    #   else
    #     @price = Price.where("artist_id=? AND label_id=? AND record_id=?", params[:record][:artist_id], params[:record][:label_id], params[:record][:record_format_id])

    #   end

    #   # binding.pry
    # end

    def set_collections
      @genres = Genre.all.map{|genre| [genre.name, genre.id]}
      @conditions = Record.condition_collection
      @record_formats = RecordFormat.all{map{|rf| [rf.name, rf.id]}}
    end

    def set_values
      @artist, @label, @record_format = @record.artist.name, @record.label.name, @record.record_format.name
    end

    def set_media
      @photo = params[:photo]=='present' ? true : false
      @audio = params[:audio]=='present' ? true : false
    end

    def set_record
      @record = Record.find(params[:id])
    end

    def record_params
      params.require(:record).permit(:identifier_id, :condition, :comment, :value, :genre_id, :price_id, :artist_id, :label_id, :record_format_id)
    end
end
