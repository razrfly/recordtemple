class PriceResource < Avo::BaseResource
  self.title = :title
  self.includes = [:artist, :label, :record_format]
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], artist_name_cont: params[:q], label_name_cont: params[:q], detail_cont: params[:q], m: "or").result(distinct: false)
  end

  action CreateRecord
  filter ArtistFilter
  filter LabelFilter
  filter RecordFormatFilter

  field :id, as: :id
  # Fields generated from the model
  # field :cached_artist, as: :text
  # field :media_type, as: :text
  # field :cached_label, as: :text
  field :detail, as: :text
  field :price_low, as: :number
  field :price_high, as: :number
  field :yearbegin, as: :number
  field :yearend, as: :number
  field :footnote, as: :textarea
  field :artist, as: :belongs_to
  field :label, as: :belongs_to
  field :record_format, as: :belongs_to
  # field :user, as: :belongs_to
  # add fields here
end
