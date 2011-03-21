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
set :branch, "stable"
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
  
  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end

after "deploy:update_code" do
  bundler.bundle_new_release
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/newrelic.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/newrelic.yml #{release_path}/config/newrelic.yml"
end
  
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
    run "for f in #{deploy_to}/#{shared_dir}/config/environments/*; do ln -nfs $f #{release_path}/config/environments; done"
    imagesdir = "#{deploy_to}/#{shared_dir}/public/images"
    run "for f in #{imagesdir}/*; do ln -nfs $f #{release_path}/public/images/; done"
    
    # install the Sugar Pond plugins
#    %w{journey_paywall journey_sugarpond_branding}.each do |plugin|
#      run "cd #{current_release} && script/plugin install -r #{branch} git+ssh://git_aegames@git.aegames.org/#{plugin}.git"
#    end
  end

  task :migrate_paywall do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release} && rake journey_paywall:migrate RAILS_ENV=#{rails_env}"
  end
end



Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
