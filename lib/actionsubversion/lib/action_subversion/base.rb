module ActionSubversion
  class InvalidRevision < StandardError 
  end
  class InvalidRepositoryPath < StandardError 
  end
  class PathForNodeEntriesIsFile < StandardError
  end
  
  class Base
  
    @@repository_path = nil
    def self.repository_path=(path); @@repository_path = path end
    def self.repository_path; @@repository_path end        
    
    #@@fs_root_cache = {} # rev -> root

    class << self
      
      # Returns a new Svn::Repos object
      def repos
        repos = SvnRepository.new(repository_path)
      end
      
      # Returns the svn fs object
      def fs
        fs ||= repos.fs
        return fs
      end
          
      # Gets the root object from a given +revision+. if +revision+
      # is nil it'll return the root object from the youngest_rev
      def fs_root(revision=nil)
        if revision
          rev = revision.to_i
        else
          rev = fs.youngest_rev
        end
        #fs_root_for_rev(rev)
        fs.root(rev)
      end

      # Returns the youngest revision found in the repository
      def get_youngest_rev 
        fs.youngest_rev
      end 
      
      protected
        # Looks up if the fs.root for +rev+ is cached, if not it creates it
        #def fs_root_for_rev(rev) #:nodoc:
        #  clear_fs_root_cache! if @@fs_root_cache.size > 25 # yes, its that dumb
        #  @@fs_root_cache[rev] ||= fs.root(rev) # Get the cached root or add it
        #end
        #
        ## clears the fs.root cache
        #def clear_fs_root_cache! #:nodoc:
        #  @@fs_root_cache.each do |rev, root| 
        #    root.close            
        #  end
        #  @@fs_root_cache = {}
        #end
              
    end 
  end
end
