module ActionSubversion

  module FileDiff
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
    
      #def unified_diff(path, rev = nil)
      #  return nil if is_dir?(path)
      #  root = fs_root(rev)
      #  old_root = fs_root(rev - 1)
      #  differ = Svn::Fs::FileDiff.new(old_root, path, root, path, pool)
      #  return nil if differ.binary?
      #  old = "Revision #{old_root.node_created_rev(path)}"
      #  cur = "Revision #{root.node_created_rev(path)}"
      #  udiff = differ.unified(old, cur)
      #end
      
      def unified_diff(path, rev = nil)
        node = repos.get_node(path, rev)
        node.udiff_with_revision(rev-1)
      end

    end # end ClassMethods
  end # end FileDiff
end