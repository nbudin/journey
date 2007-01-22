module ActionSubversion
  module FileBrowser
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods      
      # Returns a collection of RepositoryNode objects with misc. info about the file 
      # entries at +path+ and at revision +rev+:
      #
      # Accepts a string (eg 'trunk/app/models') for the +path+ a FixNum for +rev+ 
      def get_node_entries(path, rev = nil)
        node = repos.get_node(path, rev)
        entries = node.entries
      end
      
      # Returns a RepositoryNode object with misc. info about the file 
      # entries at +path+ and at revision +rev+:
      #
      # Accepts a string (eg 'trunk/app/models') for the +path+ a FixNum for +rev+
      def get_node_entry(path, rev=nil)
        node = repos.get_node(path, rev)
      end
    
      # Attempts to figure out a proper mimetype for file located at +file_path+
      # that is suitable for display in the webbrowser
      def get_mime_type(file_path, rev = nil)
        node = repos.get_node(file_path, rev)
        node.mime_type
      end    
    
      # Shows a file located at +path+ with revision +rev+.
      def get_file_contents(path, rev = nil)
        node = repos.get_node(path, rev)
        node.contents
      end
    
      # Check whether file entry located at +path+ is a dir or not
      def is_dir?(path, rev = nil)
        node = repos.get_node(path, rev)
        node.dir?
      end
    end # end ClassMethods
  end # end FileBrowser module
end 
