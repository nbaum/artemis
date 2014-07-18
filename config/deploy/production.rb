set :deploy_to, "/home/apps/#{fetch(:application)}"
set :branch, "production"

role :app, %w{}
role :web, %w{}
role :db,  %w{}
