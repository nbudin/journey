require 'bundler/capistrano'
require 'capistrano-rbenv'

load "deploy/assets"

set :user, 'deploy'

role :web, 'hempel.sugarpond.net', primary: true
role :app, 'hempel.sugarpond.net', primary: true
role :db, 'hempel.sugarpond.net', primary: true

#[:web, :app, :db].each { |r| role r, 'localhost', primary: true }
#set :ssh_options, {port: 2222, keys: ['~/.ssh/id_dsa']}

set :rbenv_path, "/opt/rbenv"
set :rbenv_setup_shell, false
set :rbenv_setup_default_environment, false
set :rbenv_setup_global_version, false
set :rbenv_ruby_version, "2.1.2"

set :application, "journey"
set :scm, :git
set :repository, "https://github.com/nbudin/journey.git"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :bundle_without, [:development, :test]

namespace(:deploy) do
  desc "Link in config files needed for environment"
  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/* #{release_path}/config/"
  end

  desc "Link in log directory"
  task :symlink_log, :roles => :app do
    run "ln -nfs #{shared_path}/log #{release_path}/log"
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

task :notify_rollbar, :roles => :app do
  set :revision, `git log -n 1 --pretty=format:"%H"`
  set :local_user, `whoami`
  rails_env = fetch(:rails_env, 'production')
  run "curl https://api.rollbar.com/api/1/deploy/ -F access_token=$(cat #{release_path}/config/application.yml |grep '^ROLLBAR_ACCESS_TOKEN:' |cut -d ' ' -f 2) -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
end

before "deploy:finalize_update", "deploy:symlink_config"
before "deploy:finalize_update", "deploy:symlink_log"
after "deploy", "deploy:cleanup"
