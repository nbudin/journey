require 'mocha'

SCOUT_DIR = File.dirname(__FILE__)

# The X-Runtime Fix and the Benchmark Fix require this constant usually set
# by config/environment.rb
(RAILS_GEM_VERSION = ActionPack::VERSION::STRING) rescue nil

# THIS IS A HACK AND MUST BE RESOLVED!
class Test::Unit::TestCase
  def setup_fixtures; end
  def teardown_fixtures; end
end

### Inject behavior into Rails (same as init.rb)

require 'scout/rails'
require 'scout/env/test'
Scout.start! do
  ActionController::Base.class_eval do
    alias_method_chain :perform_action, :instrumentation
  end
  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    alias_method_chain :log, :instrumentation
  end
end

### Mocking methods

module ScoutTestHelpers
  
  def mocked_request(runtimes = {}, params = {}, response = nil, options = {})
    runtimes = {:total => 5, :view => 2}.merge(runtimes)
    params = {:controller => "tests", :action => "index"}.merge(params)
    [runtimes, params, response, options]
  end
  
end

### Test Database

def load_schema!
  unless @schema_loaded
    config = YAML::load(IO.read(File.join(SCOUT_DIR, 'database.yml')))
    ActiveRecord::Base.logger = Logger.new(File.join(SCOUT_DIR, "debug.log"))
    
    db = begin
      require 'sqlite'; 'sqlite'
    rescue MissingSourceFile
      begin
        require 'sqlite3'; 'sqlite3'
      rescue MissingSourceFile
        raise "SQLite or SQLite3 must be installed to run the tests."
      end
    end
    
    ActiveRecord::Base.establish_connection(config[db])
    load(File.join(SCOUT_DIR, "schema.rb"))
    
    @schema_loaded = true
  end
end
