module Admin
  class PricesController < BaseController
    before_action :set_price, only: [:edit, :update]

    def edit
      @records_linked_count = @price.records.count
      @return_to = safe_return_to(params[:return_to])
      @formats = RecordFormat.order(:name).pluck(:name, :id)
    end

    def update
      @return_to = safe_return_to(params[:return_to])
      if @price.update(price_params)
        redirect_to @return_to, notice: "Price guide entry updated."
      else
        @records_linked_count = @price.records.count
        @formats = RecordFormat.order(:name).pluck(:name, :id)
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_price
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(
        :artist_id, :label_id, :record_format_id,
        :yearbegin, :yearend, :price_low, :price_high,
        :detail, :footnote, :media_type
      )
    end

    def safe_return_to(path)
      if path.is_a?(String) && !path.start_with?("//")
        normalized = Pathname.new(path).cleanpath.to_s
        return normalized if normalized.start_with?("/admin/", "/records/")
      end
      first_record = @price.records.first
      first_record ? admin_record_path(first_record) : admin_root_path
    end
  end
end
