set :application, 'app'
set :repo_url, `git remote -v`.split(/\s+/)[1]

set :bundle_binstubs, nil

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle}
set :linked_files, %w{.env config/database.yml db/production.sqlite3}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :parallel do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  task :create_default_env do
    on roles(:app), in: :parallel do
      unless test "[ -f #{shared_path.join('.env')} ]"
        upload! "SECRET_KEY_BASE=#{SecureRandom.hex(30)}", shared_path.join('.env')
      end
    end
  end
  before :check, :create_default_env
  after :publishing, :restart
end
