set :deploy_to, raise("Set deployment target")
set :branch, "staging"

role :app, %w{}
role :web, %w{}
role :db,  %w{}
