require 'capistrano/ext/multistage'

set :stages, %w{trunk}
set :default_stage, "trunk"

set :application, "journey"
set :repository, "git://github.com/nbudin/journey.git"

role :web, "ishinabe.natbudin.com"
role :app, "ishinabe.natbudin.com"
role :db,  "ishinabe.natbudin.com", :primary => true

set :user, "www-data"
set :scm, :git
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

  
after "deploy:migrate", "deploy:migrate_paywall"
after "deploy:migrations", "deploy:migrate_paywall"

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
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/journey_paywall.yml #{release_path}/config/journey_paywall.yml"
    run "rm -r #{release_path}/config/environments && mkdir #{release_path}/config/environments"
    run "for f in #{release_path}/config/environments/*; do ln -nfs $f #{release_path}/config/environments; done"
    imagesdir = "#{deploy_to}/#{shared_dir}/public/images"
    run "for f in #{imagesdir}/*; do ln -nfs $f #{release_path}/public/images/; done"
    
    # install the Sugar Pond plugins
    %w{journey_paywall journey_sugarpond_branding}.each do |plugin|
      run "cd #{current_release} && script/plugin install git+ssh://git@git.sugarpond.net/#{plugin}.git"
    end
  end

  task :migrate_paywall do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release} && rake journey_paywall:migrate RAILS_ENV=#{rails_env}"
  end
end

