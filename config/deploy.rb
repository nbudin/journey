require 'bundler/capistrano'
require 'airbrake/capistrano'
require 'capistrano-rbenv'

set :application, "journey"
set :scm, :git
set :repository, "https://github.com/nbudin/journey.git"
set :deploy_to, "/var/www/#{application}"
set :rbenv_ruby_version, "1.8.7-p371"

server "popper.sugarpond.net", :app, :web, :db, :primary => true
set :user, "www-data"
set :use_sudo, false

# change this once upgraded to rails 3.1?
set :normalize_asset_timestamps, false

namespace(:deploy) do
  desc "Link in config files needed for environment"
  task :symlink_config, :roles => :app do
    %w(database.yml journey.yml).each do |config_file|
      run <<-CMD
        ln -nfs #{shared_path}/config/#{config_file} #{release_path}/config/#{config_file}
      CMD
    end
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after "deploy:update_code", "deploy:symlink_config"
after "deploy", "deploy:cleanup"