$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..')))

require 'scout/reporter' # Scout::Reporter

class Scout
  
  # :runtime => total runtime
  # :db_runtime => time spent in SQL queries
  # :render_runtime => time spent rendering
  # :other_runtime => anything else (calls to a web service, for example)
  RUNTIMES = [:runtime, :db_runtime, :render_runtime, :other_runtime]
  
  cattr_accessor :reports, :queries, :reporter, :logger, :config
  
  class << self
    
    def start!(&initializer)
      self.reset!
      if self.load_configuration
        self.start_reporter!
        yield
      end
    end
    
    # Load configuration from YAML. Only loads once in the beginning.
    # 
    def load_configuration
      self.config = {
        :plugin_id => nil,              # must be set by user in configuration, and must match the plugin id assigned by scoutapp.com
        :explain_queries_over => 500,   # queries taking longer than this (in milliseconds) will be EXPLAINed
        :interval => 30                 # frequency of execution of the background thread, in seconds
      }
      config_path = File.expand_path(File.join(RAILS_ROOT, "config", "scout.yml"))
      
      raise LoadError.new("Could not locate configuration file #{config_path}") unless File.exists?(config_path)
      
      begin
        config = YAML.load(File.read(config_path))
        hostname = `hostname`.chomp
        
        self.config[:interval]              = config['interval']              if config['interval'].is_a?(Integer)
        self.config[:explain_queries_over]  = config['explain_queries_over']  if config['explain_queries_over'].is_a?(Integer)
        
        case id_or_hosts = config[RAILS_ENV] # load the plugin for the current environment
        
        # A Plugin ID was specified
        when Integer
          self.config[:plugin_id] = id_or_hosts
          
        # Multiple Hosts specified
        when Hash
          self.config[:plugin_id] = id_or_hosts[hostname]
          case self.config[:plugin_id]
          when NilClass, FalseClass
            return false # do not load the instrumentation
          else
            raise LoadError.new("No valid Plugin ID given.") unless self.config[:plugin_id].is_a?(Integer)
          end
          
        when NilClass, FalseClass
          return false # do not load the instrumentation
          
        else
          raise LoadError.new("Invalid configuration! Expected one or more plugin IDs but got #{id_or_hosts.inspect}")
        end
        
        begin
          require 'scout_agent/api' # ScoutAgent::API
        rescue LoadError => e
          
          raise "Unable to load the ScoutAgent::API. Make sure that you've installed the scout_agent gem.\nYou may also need to install it as root.\n%s" % e.message
        end
        
        log! :info, "Loaded with Plugin ID ##{self.config[:plugin_id]} for #{RAILS_ENV} on #{hostname}"
        return true # successfully loaded configuration
      end
    rescue Exception => e
      if RAILS_ENV == "production"
        log! :fatal, "*"*60
        log! :fatal, "Could not load Scout Instrumentation for #{RAILS_ENV} on #{hostname}."
        log! :fatal, "An error prevented starting successfully:"
        log! :fatal, "  %s" % e.message
        log! :fatal, "Disabled until the problem can be resolved."
        log! :fatal, "*"*60
      else
        log! :fatal, "Could not load Scout Instrumentation for %s on %s: %s" % [RAILS_ENV, `hostname`.chomp, e.message]
        raise e
      end
    end
    
    # Ensures that the Reporter is started.
    # 
    def start_reporter!
      # ensure that the reporter runner thread is in the right PID
      if !Reporter.runner.nil? and Reporter.runner[:pid] != $$
        Reporter.runner.exit # be nice and terminate the thread first
        Reporter.runner = nil # remove runner so new reporter will get started
      end
      # start the reporting runner thread if not started yet
      Reporter.start! if Reporter.runner.nil?
    end
    
    def reset!
      reset_reports
      reset_queries
    end
    
    def reset_reports
      self.reports = nil
    end
    
    def reset_queries
      self.queries = []
    end
    
    def record_metrics(runtimes, params, response, options = {})
      self.reports ||= self.empty_report
      
      fix_runtimes_to_ms!(runtimes) if options[:in_seconds]
      
      path = "#{params[:controller]}/#{params[:action]}"
      self.reports[:actions][path] ||= self.empty_action_report
      
      self.reports[:actions][path][:num_requests]   += 1
      self.reports[:actions][path][:runtime]        << runtimes[:total]
      db_runtime = self.queries.inject(0.0){ |total, (runtime, _)| total += runtime }
      self.reports[:actions][path][:db_runtime]     << db_runtime
      self.reports[:actions][path][:render_runtime] << runtimes[:view]
      self.reports[:actions][path][:other_runtime]  << (runtimes[:total] - runtimes[:view] - db_runtime)
      self.reports[:actions][path][:queries]        << self.queries
    end
    
    def empty_report
      {
        :actions => {}
      }
    end
    
    def empty_action_report
      {
        :num_requests     => 0,
        :runtime          => [],
        :db_runtime       => [],
        :render_runtime   => [],
        :other_runtime    => [],
        :queries          => []
      }
    end
    
    ### Utils
    
    # Logs to the Rails default logger, to STDERR, and to the Scout
    # Instrumentation log.
    # 
    def log!(level, message)
      if RAILS_ENV == "production" and [:error, :fatal].include?(level)
        self.logger.send(level, message)
        RAILS_DEFAULT_LOGGER.send(level, "** [Scout] %s" % message)
        RAILS_DEFAULT_LOGGER.flush
      end
      self.stderr.send(level, message)
    end
    
    # Fixes the runtimes to be in milliseconds.
    # 
    def fix_runtimes_to_ms!(runtimes)
      [:view, :total].each do |key|
        runtimes[key] = seconds_to_ms(runtimes[key])
      end
    end
    
    # Fix times in seconds to time in milliseconds.
    # 
    def seconds_to_ms(n)
      n * 1000.0
    end
    
    # Obfuscates SQL queries, removing literal values.
    # 
    # This has several positive side-effects:
    # * information security (sensitive data removed)
    # * recognize emerging patterns (similar queries become identical)
    # * minimize payload size (for plugin delivery)
    # 
    # Examples:
    # 
    #   obfuscate_sql("SELECT * FROM actors WHERE id = 10;")
    #   # becomes "SELECT * FROM actors WHERE id = ?;"
    #   
    #   obfuscate_sql("SELECT * FROM actors WHERE name LIKE '%jones%';")
    #   # becomes "SELECT * FROM actors WHERE name LIKE ?;"
    #   
    #   obfuscate_sql("SELECT * FROM actors WHERE secret = 'bee''s nees';")
    #   # becomes "SELECT * FROM actors WHERE secret = ?;"
    # 
    def obfuscate_sql(sql)
      # remove escaped strings (to not falsely terminate next pattern)
      sql.gsub!(/(''|\\')/, "?")
      # remove literal string values
      sql.gsub!(/'[^']*'/, "?")
      # remove literal numerical values
      sql.gsub!(/\b\d+\b/, "?")
      # remove unneeded whitespace
      sql.strip!
      sql.squeeze!(' ')
      sql
    end
    
    ### Resources
    
    def logger
      @logger ||= begin
                    logger = Logger.new(File.join(RAILS_ROOT, "log", "scout_instrumentation.log"))
                    logger.level = RAILS_DEFAULT_LOGGER.level # ActiveRecord::Base.logger.level
                    logger.formatter = proc{|s,t,p,m|"%5s [%s] %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), m]}
                    logger
                  end
    end
    
    def stderr
      @stderr ||= begin
                    logger = Logger.new(STDERR)
                    logger.level = RAILS_DEFAULT_LOGGER.level
                    logger.formatter = proc{|s,t,p,m|"** [Scout] %s\n" % [m] }
                    logger
                  end
    end
    
  end # << self
  
end
