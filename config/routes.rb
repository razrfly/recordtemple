require 'admin_constraint'

Rails.application.routes.draw do
  mount Avo::Engine, at: Avo.configuration.root_path, constraints: AdminConstraint.new
  passwordless_for :users

  root to: 'static#index'
end
