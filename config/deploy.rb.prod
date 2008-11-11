# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

#require 'mongrel_cluster/recipes'

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "journey"
set :repository, "http://journey-questionnaires.googlecode.com/svn/branches/2.5"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "sakai.natbudin.com"
role :app, "sakai.natbudin.com"
role :db,  "sakai.natbudin.com", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/var/www/journey.aegames.org" # defaults to "/u/apps/#{application}"
#set :use_sudo, true
set :checkout, "export"
set :user, "www-data"            # defaults to the currently logged in user
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :scm, :subversion               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

namespace :deploy do
  desc "Tell Passenger to restart this app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Link in database config, images, and frozen rails"
  task :after_update_code do
    run "rm -f #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
    imagesdir = "#{deploy_to}/#{shared_dir}/public/images"
    run "for f in #{imagesdir}/*; do ln -nfs $f #{release_path}/public/images/; done"
  #  run "cd #{release_path} ; rake bootstrap RAILS_ENV=production"
  end
end

