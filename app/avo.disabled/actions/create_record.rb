class CreateRecord < Avo::BaseAction
  self.name = "Create record"
  self.visible = -> do
    if view == :show
      true
    else
      false
    end
  end

  #field :genre_id, as: :select, options: ::Genre.all.map { |g| [g.name, g.id] }
  field :genre_id, as: :select, options: ->(model:, resource:, view:, field:) do
    ::Genre.all.map { |g| [g.name, g.id] }
  end
  field :comment, as: :textarea
  field :value, as: :number
  field :condition, as: :select, enum: ::Record.conditions

  def handle(**args)
    models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)
    #models, fields = args.values_at(:models, :fields)
    models.each do |model|
      # Do something with your models.
      record = model.records.build(
        artist_id: model.artist_id,
        label_id: model.label_id,
        user_id: current_user.id,
        record_format_id: model.record_format_id,
        comment: fields[:comment],
        value: fields[:value],
        genre_id: fields[:genre_id],
        condition: fields[:condition]
      )
      if record.save!
        succeed 'Yup'
        redirect_to avo.resources_record_path(record)
      else
        fail 'Error'
      end
    end
  end
end
