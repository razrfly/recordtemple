class Admin::PricesController < Admin::AdminController
  before_action :set_price, only: [:show, :edit, :update, :destroy]
  before_action :set_price_range, only: :index
  def index
    @search = Price.ransack(params[:q])
    @prices = @search.result.page(params[:page])
    @record_formats = RecordFormat.with_prices
  end

  def show
    @records = @price.records.where(user: current_user).page(params[:records_page])
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
      redirect_to admin_price_path(@price), :notice => "Price was successfully created."
    else
      render :new
    end
  end

  def update
    if @price.update_attributes(price_params)
      redirect_to admin_price_path(@price), :notice => "Price was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @price.destroy
    redirect_to admin_price_path(@price), :notice => "Price was successfully deleted."
  end

  private
    def set_price
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(:artist_id, :label_id, :detail, :record_format_id, :footnote)
    end

    def set_price_range
      @price_collection = {'greater than' => :gt, 'lower than' => :lt, 'equals' => :eq}
      @price_low_selected, @price_high_selected = params[:js_select_price_low], params[:js_select_price_high]
    end
end
