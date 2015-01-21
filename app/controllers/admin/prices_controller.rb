class Admin::PricesController < Admin::AdminController
  before_action :set_price, only: [:show, :edit, :update, :destroy]
  before_action :set_price_range, only: :index
  def index
    @search = Price.ransack(params[:q])
    @prices = @search.result.page(params[:page])
    @record_formats = RecordFormat.all.map{|rf| rf if rf.records.size>0 }.compact
  end

  def show
    respond_to do |format|
      format.html
      format.json {
        render json: {artist: @price.artist.name, label: @price.label.name, format: @price.record_format.name }.to_json }
    end
  end

  def new
    @price = Price.new
  end

  def edit
  end

  def create
    @price = Price.new(price_params)

    if @price.save
      redirect_to admin_artist_path(@artist), :notice => "Price was successfully created."
    else
      render :new
    end
  end

  def update
    if @price.update_attributes(price_params)
      redirect_to admin_artist_path(@artist), :notice => "Price was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @price.destroy
    redirect_to admin_artist_path(@artist), :notice => "Price was successfully deleted."
  end

  private
    def set_price
      #@artist = Artist.find(params[:artist_id])
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(:label_id, :detail, :record_type_id, :footnote)
    end

    #FIIIIX ME
    def set_price_range
      @price_high_select = params[:js_select_price_high]
      @price_low_select = params[:js_select_price_low]
      if params[:q]
        @value_high = params[:q][:price_high_lt] || params[:q][:price_high_gt] || params[:q][:price_high_eq]
        @value_low = params[:q][:price_low_lt] || params[:q][:price_low_gt] || params[:q][:price_low_eq]

        if params[:q][:price_high_lt]
          @price_high = :price_high_lt
        elsif params[:q][:price_high_gt]
          @price_high = :price_high_gt
        elsif params[:q][:price_high_eq]
          @price_high = :price_high_eq
        end
        if params[:q][:price_low_lt]
          @price_low = :price_low_lt
        elsif params[:q][:price_low_gt]
          @price_low = :price_low_gt
        elsif params[:q][:price_low_eq]
          @price_low = :price_low_eq
        end
      end
    end
end
