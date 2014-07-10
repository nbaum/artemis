set :application, 'app'
set :repo_url, raise("Set repo")

set :bundle_binstubs, nil

set :linked_files, %w{config/database.yml .env}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 1 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :publishing, :restart
end
