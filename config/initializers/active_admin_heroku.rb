if Rails.env.production?
  require 'fileutils'
  FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets", "admin"))

  template_path_one = "#{Gem.loaded_specs['activeadmin'].full_gem_path}/app/assets/stylesheets"
  template_path_two = "#{Gem.loaded_specs['activeadmin'].full_gem_path}/lib/active_admin/sass"
  old_compile_path = "#{Rails.root}/public/stylesheets/admin"
  new_compile_path = "#{Rails.root}/tmp/stylesheets/admin"

  Sass::Plugin::remove_template_location template_path_one
  Sass::Plugin::add_template_location template_path_one, new_compile_path

  Sass::Plugin::remove_template_location template_path_two
  Sass::Plugin::add_template_location template_path_two, new_compile_path
else
  activeadmin_reloader = ActiveSupport::FileUpdateChecker.new(Dir["app/admin/**/*"], true) do

    ActiveAdmin.application.unload!
    Rails.application.reload_routes!
  end

  ActionDispatch::Callbacks.to_prepare do
    activeadmin_reloader.execute_if_updated
  end
end