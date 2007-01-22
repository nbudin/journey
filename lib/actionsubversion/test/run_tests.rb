#!/usr/bin/env ruby

require "test/unit"

$:.unshift(File.dirname(__FILE__))

test_files =  [ 'file_browser_test.rb',
                'mime_finder_test.rb',
                'changeset_finder_test.rb',
                'file_diff_test.rb',
                'repository_node_test.rb'
                ]
        
test_files.each do |file|
  Test::Unit::AutoRunner.run(false, file)
end