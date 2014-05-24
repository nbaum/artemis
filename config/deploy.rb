# config valid only for Capistrano 3.2
lock '3.2.1'

set :application, raise("Set application name, for some reason")
set :repo_url, raise("Set appliction repo")

set :deploy_to, raise("Set deployment target")

set :linked_dirs, %w{tmp log}
set :linked_files, %w{.env db/production.sqlite tmp/token.txt}

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

end
