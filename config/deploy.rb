require 'capistrano/ext/multistage'

set :stages, %w{trunk}
set :default_stage, "trunk"

set :application, "journey"
set :repository, "git://github.com/nbudin/journey.git"

role :web, "sakai.natbudin.com"
role :app, "sakai.natbudin.com"
role :db,  "sakai.natbudin.com", :primary => true

set :checkout, "export"
set :user, "www-data"
set :scm, :git
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
  desc "Tell Passenger to restart this app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Link in database config, images, and frozen rails"
  task :after_update_code do
    run "rm -f #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    imagesdir = "#{deploy_to}/#{shared_dir}/public/images"
    run "for f in #{imagesdir}/*; do ln -nfs $f #{release_path}/public/images/; done"
  end
end

