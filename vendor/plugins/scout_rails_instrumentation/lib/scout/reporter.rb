class Scout
  # Reporter relies on two configuration settings:
  # * config[:plugin_id]: the plugin id provided in the users' account at
  #                       scoutapp.com. User provides this the config file.
  # * config[:interval]: the interval at which the instrumentation runs in
  #                      seconds. 30 is the default.
  #                      It is unusual for the user to need to change this.
  # 
  # Optional configuration options include:
  # * config[:explain_queries_over]: run EXPLAINs for any queries that take
  #                                  longer than this (in milliseconds).
  # 
  class Reporter
    cattr_accessor :runner, :interval
    LOCK = Mutex.new
    
    class << self
      
      def reset!
        self.runner.exit rescue nil
        self.runner = nil
      end
      
      def start!(interval = Scout.config[:interval].seconds)
        self.interval = interval.to_i
        self.runner ||= begin
          Thread.new(self) do |reporter|
            Thread.current[:pid] = $$ # record where thread is running,
                                      # so we can remove runaways (Passenger)
            sleep(rand(15)) # stagger report cycles among running processes
            loop do
              sleep(self.interval)
              reporter.run
            end
          end
        end
        self.runner.run # start the report loop
      end
      
      def run
        begin
          self.report!
        rescue Exception => e
          raise unless self.handle_exception!(e)
        end
      end
      
      def report!
        return if Scout.reports.nil? or Scout.reports[:actions].empty? # no report is necessary
        
        report_time = Time.now.utc
        timestamp = report_time.strftime("%Y-%m-%d %H:%I:%S (%s)")
        report = nil
        
        # atomically pull out the report then reset
        LOCK.synchronize do
          # essentially we're blocking the reports from being modified until
          # after we've secured the contents of the report.
          report = Scout.reports.dup
          Scout.reset! # reset the accumulated reports
        end
        
        report[:time] = report_time
        report[:snapshot] = false # do not take a snapshot by default
        
        # calculate report runtimes
        calculate_report_runtimes!(report)
        
        # calculate average request time and number of requests
        report[:avg_request_time], report[:num_requests] = calculate_avg_request_time_and_num_requests(report)
        
        run_explains_for_slow_queries!(report)
        
        # take snapshot if an explain was run
        if report.delete(:snapshot)
          logger.debug "Snapshot taken"
          ScoutAgent::API.take_snapshot
        end
        
        obfuscate_queries!(report)
        minimize_query_duplication!(report)
        
        # enqueue the message for background processing
        begin
          response = ScoutAgent::API.queue_for_mission(Scout.config[:plugin_id], report)
          if response.success?
            logger.debug "Report queued"
            logger.debug "Report size: %i" % report.to_json.length
            # logger.debug "Report: %s" % report.to_json
          else
            logger.error "Error:  #{response.error_message} (#{response.error_code})"
            logger.debug "Failed report: %s" % report.inspect
          end
          
        end
      end
      
      def handle_exception!(e)
        case e
        when Timeout::Error
          logger.error "Unable to queue the report, the agent timed out"
          logger.debug "+ abridged backtrace:\n\t%s" % e.backtrace[0..15].join("\n\t")
        when Exception
          logger.error "An unexpected error occurred while reporting: #{e.message}"
          logger.error "%s\n\t%s" % [e.inspect, e.backtrace.join("\n\t")]
          logger.debug "Failed report: %s" % report.inspect
        end
      end
      
      def calculate_report_runtimes!(report)
        report[:actions].each do |(path, action)|
          RUNTIMES.each do |runtime|
            runtimes = report[:actions][path].delete(runtime)
            avg, max = calculate_avg_and_max_runtimes(runtimes, action[:num_requests])
            report[:actions][path]["#{runtime}_avg".to_sym] = avg
            report[:actions][path]["#{runtime}_max".to_sym] = max
          end
        end
      end
      
      def calculate_avg_and_max_runtimes(runtimes, num_requests)
        [(runtimes.sum / num_requests.to_f), runtimes.max]
      end
      
      def calculate_avg_request_time_and_num_requests(report)
        total_num_requests = report[:actions].map{|(p,a)| a[:num_requests] }.sum
        avg_request_time = report[:actions].map{|(p,a)| a[:runtime_avg]*a[:num_requests] }.sum / total_num_requests
        [avg_request_time, total_num_requests]
      end
      
      def run_explains_for_slow_queries!(report)
        report[:actions].each do |(path, action)|
          action[:queries].each_with_index do |queries, i|
            queries.each_with_index do |(ms, sql), j|
              if sql =~ /^SELECT /i and ms > Scout.config[:explain_queries_over]
                report[:actions][path][:queries][i][j] << ActiveRecord::Base.connection.explain(sql)
                report[:snapshot] = true
              end
            end
          end
        end
      rescue Exception => e
        logger.error "An error occurred EXPLAINing a query: %s" % e.message
        # logger.error "\t%s" % e.backtrace.join("\n\t") # unneeded
      end
      
      def obfuscate_queries!(report)
        report[:actions].each do |(path, action)|
          action[:queries].each_with_index do |queries, i|
            queries.each_with_index do |(ms, sql), j|
              report[:actions][path][:queries][i][j][1] = Scout.obfuscate_sql(sql)
            end
          end
        end
      end
      
      def minimize_query_duplication!(report)
        report[:queries] = []
        report[:actions].each do |(path, action)|
          action[:queries].each_with_index do |queries, i|
            queries.each_with_index do |(ms, sql), j|
              index = report[:queries].index(sql)
              unless index
                index = report[:queries].length
                report[:queries] << sql
              end
              report[:actions][path][:queries][i][j][1] = index
            end
          end
        end
      end
      
      def logger(*args)
        Scout.logger(*args)
      end
      
    end
    
    # This is a mocking method so that we can put an instance of a Reporter in
    # place of a real Thread for testing purposes.
    # 
    def run
      self.class.run
    end
    
  end
end
