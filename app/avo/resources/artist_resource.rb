class ArtistResource < Avo::BaseResource
  self.title = :name
  self.default_view_type = :grid
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false).order(name: :asc)
  end
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(name: :asc)
  end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text, sortable: true
  field :slug, as: :text, only_on: :edit

  tabs do
    field :records, as: :has_many, link_to_resource: true
    field :prices, as: :has_many, link_to_resource: true
    field :labels, as: :has_many, link_to_resource: true
  end

  grid do
    cover 'cover', as: :external_image, link_to_resource: true do |model|
      model.cover.url if model.cover.present?
    end
    title :name, as: :text, link_to_resource: true
    # body :content, as: :text do |model|
    #   model.content.to_plain_text.truncate(80)
    # end
  end

  filter PublishedFilter
end
