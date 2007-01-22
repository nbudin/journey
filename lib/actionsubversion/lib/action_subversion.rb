require 'time'
require 'ostruct'

require 'svn/core'
require 'svn/fs'
require 'svn/delta'
require 'svn/repos'

$:.unshift(File.dirname(__FILE__))
require 'action_subversion/base'
require 'action_subversion/mime_finder'
require 'action_subversion/file_browser'
require 'action_subversion/changeset_finder'
require 'action_subversion/file_diff'

require 'action_subversion/repository_node'

ActionSubversion::Base.class_eval do
  include ActionSubversion::FileBrowser
  include ActionSubversion::MimeFinder
  include ActionSubversion::ChangesetFinder
  include ActionSubversion::FileDiff
end