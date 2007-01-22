require 'iconv'

module ActionSubversion   
  
  class SvnRepository
    def initialize(repos_path)
      repos_path = sanitize_repos_path(repos_path)
      @repos = Svn::Repos.open(repos_path)
      @fs = @repos.fs
    end
    attr_accessor :repos, :fs
    
    def get_node(path, rev)
      RepositoryNode.new(path, @fs, rev)
    end
    
    private
      def sanitize_repos_path(path)
        return path.chomp('/')
      end
  end
  
  class RepositoryNode
        
    def initialize(fullpath, fs, rev=nil)
      @fs = fs
      @rev = rev || @fs.youngest_rev
      @rev = @rev.to_i unless @rev.nil?
      @path = fullpath
      @root = @fs.root(@rev)
    end
    attr_accessor :path, :root
    
    def entries
      node_type = @root.check_path(@path)
      if node_type == Svn::Core::NODE_DIR
        dir_entries = @root.dir_entries(@path).keys        
        entries = dir_entries.map do |entry|
          fullpath = File.join(path, entry)
          self.class.new(fullpath, @fs, @rev)
        end
      else # this isn't a directory
        entries = nil
      end
      entries
    end
    
    def revision 
      @root.node_created_rev(@path)
    end
    
    def name
      if self.dir?
        if @path =~ /\/$/
          File.basename(@path)
        else
          File.basename(@path) + '/'
        end
      else
        File.basename(@path)
      end
    end
    
    def dir?
      @root.dir?(@path)
    end
    
    def file?
      !self.dir?
    end
    
    # FIXME: unneeded really
    def type
      self.dir? ? 'Dir' : 'File'
    end
    
    def is_textual?
      self.mime_type.downcase =~ /^text/ 
    end
    
    def is_image?
      self.mime_type.downcase =~ /image\/(png|jpg|jpeg|gif)/
    end
    
    def is_binary?  
      return if self.mime_type.nil?
      Svn::Core.binary_mime_type?(self.mime_type)
    end

    def author
      @fs.prop(Svn::Core::PROP_REVISION_AUTHOR, revision).to_s
    end

    def date
      @fs.prop(Svn::Core::PROP_REVISION_DATE, revision)
    end
    alias_method :mtime, :date
    alias_method :modified, :date

    def log
      @fs.prop(Svn::Core::PROP_REVISION_LOG, revision) || ''
    end
    alias_method :log_message, :log
  
    def mime_type
      return '' if self.dir?
      mime = @root.node_prop(@path, Svn::Core::PROP_MIME_TYPE)
      if not mime
        mime = Base.get_mime_type_by_extension(self.name)
      # svn got a habit of assigning application/octet-stream to lots of texty files
      elsif mime == 'application/octet-stream' 
        if Base.get_mime_type_by_extension(self.name)
          mime = Base.get_mime_type_by_extension(self.name)
        end
      end
      mime
    end
    
    def contents
      return if self.dir?

      contents = @root.file_contents(@path){|s| s.read(size) }

      if self.mime_type.nil?
        charset = "utf-8"
      else
        charset = self.mime_type.slice(/charset=([A-Za-z0-9\-_]+)/, 1) || "utf-8"
        self.mime_type.sub!(/;.*/, "")
      end
      # TODO: look over properly
      convert_to_utf8(contents, charset)
    end
    
    def size
      if self.file?
        @root.file_length(@path).to_i
      else
        0
      end
    end
    
    def proplist
      @root.node_proplist(@path)
    end
    
    def udiff_with_revision(rev)
      old_root = @fs.root(rev)
      differ = Svn::Fs::FileDiff.new(old_root, @path, @root, @path)
      return nil if differ.binary?
      old = "Revision #{old_root.node_created_rev(path)}"
      cur = "Revision #{@root.node_created_rev(path)}"
      udiff = differ.unified(old, cur)      
    end

    private
      def convert_to_utf8(src, src_charset)
        if src_charset == "utf-8"
          return src
        end
        begin
          return Iconv.conv("utf-8", src_charset, src)
        rescue
          return src
        end
      end
      
      #def parse_date(date_str)
      #  date = Time.from_svn_format(date_str)
      #end      
  end
end