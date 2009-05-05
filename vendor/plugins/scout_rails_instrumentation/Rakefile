require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'test/unit'

desc "Run tests"
task :default => :test

desc "Run test"
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern ='test/**/*_test.rb'
  t.verbose = true
end
