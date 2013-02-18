# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/switchtower.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

require 'tasks/rails'

journey_paywall = Gem.searcher.find('journey_paywall')
if journey_paywall
  Dir["#{journey_paywall.full_gem_path}/tasks/*.rake"].each { |ext| load ext }
end
