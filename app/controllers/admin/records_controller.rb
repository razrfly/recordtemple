class Admin::RecordsController < Admin::AdminController
  authorize_resource
  before_action :set_record, only: [:show, :edit, :update, :destroy, :unlink_price]
  before_action :set_price, only: [:new, :create, :edit, :update, :show]
  before_action :set_collections, only: [:edit, :new, :create, :update]
  before_action :set_values, only: [:edit, :update]

  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.includes(:artist, :label, :genre, :price, :photos, :record_format).where(user: current_user).uniq

    @record_formats = RecordFormat.with_records current_user
    @genres = Genre.with_records current_user
    @conditions = Record.condition_collection

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
    2.times do
      @record.photos.build
      @record.songs.build
    end
  end

  def edit
    @record.photos.build
    @record.songs.build
  end

  def create
    @record = Record.new ({user: current_user, artist: @artist, label: @label, record_format: @record_format, price: @price}).merge record_params
    if @record.save
      redirect_to [:admin, @record], notice: 'Please verify all the details and music or photos!'
    else
      render action: "new"
    end
  end

  def update
    if @record.update_attributes record_params
      redirect_to [:admin, @record], notice: 'Record was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @record.destroy
    redirect_to [:admin, :records]
  end

  def unlink_price
    @record.update(price_id: nil)
    redirect_to [:edit, :admin, @record]
  end


  private

    def set_price
      if params[:price_id]
        @price = Price.find(params[:price_id])
        @artist, @label, @record_format = @price.artist, @price.label, @price.record_format
      else
        @price = @record.price if @record
      end
    end

    def set_collections
      @genres = Genre.all.map{|genre| [genre.name, genre.id]}
      @conditions = Record.condition_collection
      @record_formats = RecordFormat.all{map{|rf| [rf.name, rf.id]}}
    end

    def set_values
      @artist, @label, @record_format = @record.artist.name, @record.label.name, @record.record_format.name
    end

    def set_record
      @record = Record.find(params[:id])
    end

    def record_params
      params.require(:record).permit(:identifier_id, :condition, :comment, :value, :genre_id, :price_id, :artist_id, :label_id, :record_format_id,
        :photos_attributes => [:id, :image, :_destroy],
        :songs_attributes => [:id, :audio, :title, :_destroy])
    end
end
