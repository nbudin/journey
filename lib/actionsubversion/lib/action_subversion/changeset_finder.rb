module ActionSubversion
  module ChangesetFinder 
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
    
      # Finds all affected files and dirs for a  given revision
      #
      # Example usage: 
      #   # Get an array of all added files from revision 42
      #   changeset = ActionSubversion::ChangesetFinder.new(42)
      #   changeset.added_files #=> ['trunk/file1.txt', 'trunk/file2.txt']
      #
      # copied_nodes & moved_nodes outputs the following array in an array of files/dirs:
      # [to_path, from_path, from_rev]
      # All others only return the changed path(s) in an array
      def get_changeset(rev)
        unless rev.is_a?(Fixnum)
          rev = rev.to_i
        end

        if not rev_valid?(rev)
          raise InvalidRevision
        else
          editor = traverse(Svn::Delta::ChangedEditor, rev, true)
          # FIXME: All of this really needs to be nailed properly, 
          # the crazy array juggling is prone to bugger out and is generally inefficient
          pre_deleted_nodes = editor.deleted_dirs + editor.deleted_files
          pre_copied_nodes = editor.copied_dirs + editor.copied_files
          added_nodes = editor.added_dirs + editor.added_files
          updated_nodes = editor.updated_dirs + editor.updated_files
          
          moved_nodes = []          
          pre_copied_nodes.each do |c|
            if pre_deleted_nodes.include? c[1]
              moved_nodes.push(c)
              # Reject matching items in pre_deleted_nodes
              # Since they'll turn up in there when a move has happened otherwise
              pre_deleted_nodes.reject!{|d| d == c[1]}
            end
            # HACK: remove any added_nodes matching the copy
            #added_nodes.reject!{|a| a[0..(c[0].length - 1)] == c[0]}
          end
          # subtract any moved nodes from the copied nodes
          # Since they'll turn up in both for a move otherwise
          copied_nodes = pre_copied_nodes - moved_nodes 
          deleted_nodes = pre_deleted_nodes
          
          props = {
                  # Get the props for the given revision
                  :author       => fs.prop(Svn::Core::PROP_REVISION_AUTHOR, rev),
                  :log_message  => fs.prop(Svn::Core::PROP_REVISION_LOG, rev),
                  :date         => fs.prop(Svn::Core::PROP_REVISION_DATE, rev),
                  
                  :deleted_nodes  => deleted_nodes,
                  :copied_nodes   => copied_nodes,
                  :added_nodes    => added_nodes,
                  :updated_nodes => updated_nodes,
                  :moved_nodes => moved_nodes,
                  }
          return OpenStruct.new(props)
        end
      end
    
      private
        #def parse_date(date_str)
        #  date = Time.from_svn_format(date_str)
        #end
      
        def rev_valid?(rev)
          true if rev <= fs.youngest_rev
        end
      
        # Traverses an editor class
        def traverse(editor_class, rev, pass_root=false)
          fs = repos.fs
          root = fs.root(rev)
          base_rev = rev - 1
          base_root = fs.root(base_rev)
          if pass_root
            editor = editor_class.new(root, base_root)
          else
            editor = editor_class.new
          end
          base_root.dir_delta("", "", root, "", editor)
          editor
        end
      end # end ClassMethods
  end  # end ChangesetFinder
end
