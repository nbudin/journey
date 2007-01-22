class Checkout < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  validates_associated :project, :user
  before_create :do_checkout
  after_destroy :remove_checkout
  
  def do_checkout
    self.path = File.join(JOURNEY_WORKDIR, @user.id.to_s, @project.id.to_s)
    if not File.exists? File.join(path, ".svn")
      FileUtils.mkdir_p path
      
      # fork in order to shield other processes from the effects of chdir
      pid = Process.fork
      if not pid
        Dir.chdir path
        cmd = "svn checkout"
        cmd += " --username #{@project.username}" if @project.username
        cmd += " --password #{@project.password}" if @project.password
        cmd += " #{@project.repo_url} #{path}"
        logger.info "Executing #{cmd}"
        exec cmd
      else
        Process.wait pid, 0
        if $?.exitstatus != 0
          return false
        end
      end
    end
  end
  
  def remove_checkout
    FileUtils.rm_r path #, :secure => true -- I need to find out a way to make this option work
  end
end
