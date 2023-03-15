require 'admin_constraint'
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Avo::Engine, at: Avo.configuration.root_path, constraints: AdminConstraint.new
  mount Sidekiq::Web => "admin/sidekiq", constraints: AdminConstraint.new
  passwordless_for :users

  root to: 'static#index'
end
