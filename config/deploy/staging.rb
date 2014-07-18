set :deploy_to, "/home/apps/#{fetch(:application)}"
set :branch, "staging"

role :app, %w{}
role :web, %w{}
role :db,  %w{}
