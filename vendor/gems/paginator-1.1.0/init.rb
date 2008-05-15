
require_options = ["paginator"]
if require_lib = require_options.find { |path|  File.directory?(File.join(File.dirname(__FILE__), 'lib', path) || File.file?(File.join(File.dirname(__FILE__), 'lib', "#{path}.rb")) }
  require File.join(File.dirname(__FILE__), 'lib', require_lib)
else
  puts msg = "ERROR: Please update #{File.expand_path __FILE__} with the require path for linked RubyGem paginator"
  exit
end

