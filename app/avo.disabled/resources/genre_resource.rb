class GenreResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :slug, as: :text, only_on: :edit

  tabs do
    field :records, as: :has_many, link_to_resource: true
  end
end
