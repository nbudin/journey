# This file is executed when the plugin is installed. It sets up the
# configuration file and provides next steps to put the plugin to use.

RAILS_ROOT = File.join(File.dirname(__FILE__), '..', '..', '..') unless defined?(RAILS_ROOT)

# template 
config_file_name = 'scout.yml'
template_path = File.join(File.dirname(__FILE__), 'assets', 'scout_config_template')
path = File.expand_path(File.join(RAILS_ROOT, 'config', config_file_name))

if File.exists?(path)
  puts "You already have a configuration file at #{path}. We've left it as-is."
  puts "This is normal if you've re-installed the plugin."
  puts "However, please check #{File.expand_path(template_path)}"
  puts "to see if anything has changed since your config file was created."
else
  File.open(path, "w") do |f|
    f.puts IO.read(template_path)
  end
end

puts File.read(File.join(File.dirname(__FILE__), 'welcome.txt')).gsub(config_file_name, path)
