set :deploy_to, raise("Set deployment target")
set :branch, "production"

role :app, %w{}
role :web, %w{}
role :db,  %w{}
