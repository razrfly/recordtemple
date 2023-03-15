class RecordResource < Avo::BaseResource
  self.title = :title
  self.includes = [:artist, :label, :record_format, :genre]
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], comment_cont: params[:q], m: "or").result(distinct: false)
  end
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(created_at: :desc)
  end

  field :id, as: :id
  field 'cover', as: :external_image, link_to_resource: true, only_on: :index do |model|
    model.images.first.url if model.images.any?
  end
  # Fields generated from the model
  field :artist, as: :belongs_to, searchable: true#, sortable: true
  field :label, as: :belongs_to, searchable: true#, sortable: true
  
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

  field :images, as: :files, is_image: true, link_to_resource: true
  field :songs, as: :files, link_to_resource: true

  # sidebar do
  #   field :images, as: :files, is_image: true, link_to_resource: true
  #   field :songs, as: :files, link_to_resource: true
  # end

  panel name: "Price Guide", description: "Details from the Price Guide" do
    field :price_low, as: :number
    field :price_high, as: :number
    field :yearbegin, as: :number
    field :yearend, as: :number
    field :details, as: :text
    field :footnote, as: :text
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
