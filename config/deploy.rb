lock '3.4.0'

set :rbenv_ruby, '2.6.2'
set :rbenv_custom_path, "/opt/rbenv"

set :application, 'journey'
set :repo_url, "https://github.com/nbudin/journey.git"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  desc 'Notify Rollbar of the deploy'
  task :notify_rollbar do
    on roles(:app) do |h|
      revision = `git log -n 1 --pretty=format:"%H"`
      local_user = `whoami`
      rails_env = fetch(:rails_env, 'production')
      execute "curl https://api.rollbar.com/api/1/deploy/ -F access_token=$(cat #{release_path}/config/application.yml |grep '^ROLLBAR_ACCESS_TOKEN:' |cut -d ' ' -f 2) -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
    end
  end

  after :deploy, 'notify_rollbar'

end
