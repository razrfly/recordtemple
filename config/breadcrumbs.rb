crumb :root do
  link "Home", root_path
end

# This is just for create crumbs from
# any provided attributes like for ex.:
# /:artist-name-:label_name

slug_helper = ->(*args){
    args.reject(&:blank?).join('-').parameterize
  }

#Records crumbs
  crumb :records do
    link "Records", records_path
  end

  crumb :new_record do
    link "New", new_record_path
    parent :records
  end

  crumb :record do |record|
    slug = slug_helper.(record.artist_name, record.label_name)

    link slug, record_path(record)
    parent :records
  end

  crumb :edit_record do |record|
    link "Edit", edit_record_path(record)
    parent :record, record
  end

#Labels crumbs
  crumb :labels do
    link "Labels", labels_path
  end

  crumb :label do |label|
    link label.name.parameterize, label_path(label)
    parent :labels
  end

#Artist crumbs
  crumb :artists do
    link "Artist", artists_path
  end

  crumb :artist do |artist|
    link artist.name.parameterize, artist_path(artist)
    parent :artists
  end


# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).