class RecordResource < Avo::BaseResource
  self.title = :title
  self.includes = [:artist, :label, :record_format, :genre, :price]
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], comment_cont: params[:q], m: "or").result(distinct: false).order(created_at: :desc)
  end
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(created_at: :desc)
  end

  field :id, as: :id
  field :artist, as: :belongs_to, searchable: true, only_on: :index
  field :label, as: :belongs_to, searchable: true, only_on: :index 
  field :images, as: :files, is_image: true, link_to_resource: true
  # field 'cover', as: :external_image, link_to_resource: true, only_on: :index do |model|
  #   model.images.first.url if model.images.any?
  # end
  field :value, as: :number
  field :comment, as: :textarea

  field :condition,
    as: :select,
    enum: ::Record.conditions,
    display_with_value: true,
    placeholder: 'Choose the condition.'
  
  field :identifier, as: :number
  #field :user, as: :belongs_to
  field :price, as: :belongs_to, searchable: true, hide_on: :index
  field :genre, as: :belongs_to
  field :record_format, as: :belongs_to


  sidebar do
    # heading "Record Details"
    heading "Record Details"
    field :artist, as: :belongs_to, searchable: true
    field :label, as: :belongs_to, searchable: true
    # price guide
    heading "Price Guide"
    field :price_low, as: :number, hide_on: [:new, :edit]
    field :price_high, as: :number, hide_on: [:new, :edit]
    field :yearbegin, as: :number, hide_on: [:new, :edit]
    field :yearend, as: :number, hide_on: [:new, :edit]
    field :details, as: :text, hide_on: [:new, :edit]
    field :footnote, as: :text, hide_on: [:new, :edit]
  end

  panel name: "Tracks", description: "Songs" do
    field :songs, as: :files, link_to_resource: true
  end

  grid do
    cover 'cover', as: :external_image, link_to_resource: true do |model|
      model.images.first.url if model.images.any?
    end
    title :title, as: :text, link_to_resource: true
    # body :content, as: :text do |model|
    #   model.content.to_plain_text.truncate(80)
    # end
  end
  
  filter AssetFilter
  
  # add fields here
end
