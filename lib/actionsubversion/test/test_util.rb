require "fileutils"
require 'test/unit'


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'action_subversion'

module ActionSubversionTestUtil
  
  def setup_repos
    @author = ENV["USER"] || "sample-user"
    @password = "sample-password"
    @realm = "sample realm"
    @repos_path = File.join(Dir.pwd, "repos_for_tests")
    @full_repos_path = File.expand_path(@repos_path)
    setup_repository(@repos_path)
    @repos = Svn::Repos.open(@repos_path)
    @fs = @repos.fs
    add_files_to_repos

    ActionSubversion::Base.repository_path = @full_repos_path
    #ActionSubversion::Base.connect          
  end

  def teardown_repos
    #ActionSubversion::Base.close_connection
    teardown_repository(@repos_path)
    FileUtils.rm_rf(@full_repos_path) # repos
  end

  def setup_repository(path, config={}, fs_config={})
    FileUtils.mkdir_p(File.dirname(path))
    Svn::Repos.create(path, config, fs_config)
    #`svnadmin create #{path}`
  end

  def teardown_repository(path)
    Svn::Repos.delete(path)
  end
  
  def add_files_to_repos
    `cat #{File.dirname(__FILE__)}/fixtures/data_for_tests.svn|svnadmin load #{@full_repos_path}`
  end
  
end
