$scout_reporter = {}

class Scout
  
  class << self
    
    def load_configuration
      self.config = {
        :plugin_id => 1,              # must be set by user in configuration, and must match the plugin id assigned by scoutapp.com
        :explain_queries_over => 100,   # queries taking longer than this (in milliseconds) will be EXPLAINed
        :interval => 30                 # frequency of execution of the background thread, in seconds
      }
      true # so that the startup event occurs
    end
    
  end
  
  class Reporter
    class << self
      
      def run_with_test_hooks
        $scout_reporter[:last_run] = Time.now
        $scout_reporter[:last_result] = run_without_test_hooks
      end
      alias_method_chain :run, :test_hooks
      
    end
  end
  
end
