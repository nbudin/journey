class ActionController::Base
  def perform_action_with_instrumentation
    action_output = nil
    runtimes = {}
    
    Scout.start_reporter! # ensure reporter is started
    Scout.reset_queries # collects queries only for this action
    
    runtimes[:benchmark] = Benchmark.ms do
      action_output = perform_action_without_instrumentation
    end
    
    # make sure that the action completed successfully (otherwise, both will be
    # nil). We suppress failure because most production systems will have email
    # notifications etc.
    if @rendering_runtime || @view_runtime
      # ActiveRecord::Base.connection.reset_runtime resets the runtime so it is
      # unreliable (other plugins/parts of Rails call it).
      # Instead, sum the total runtime of the queries.
      # runtimes[:db] = ActiveRecord::Base.connection.reset_runtime + (@db_rt_before_render || 0.0) + (@db_rt_after_render || 0.0)
      runtimes[:view] = @rendering_runtime || @view_runtime
      runtimes[:total] = response.headers["X-Runtime"].to_f # runtimes[:db] + runtimes[:view] + time_in_controller + time_in_framework
      
      # @view_runtime is 2.2.2+ and is a good indication of the change from seconds to milliseconds
      Scout.record_metrics(runtimes, params, response, :in_seconds => @view_runtime.nil?)
    end
    
    action_output
  end
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def log_with_instrumentation(sql, name, &block)
    start_time = Time.now
    results = log_without_instrumentation(sql, name, &block)
    
    unless Scout.queries.nil?
      Scout.queries << [Scout.seconds_to_ms(Time.now - start_time), sql]
    end
    
    results
  end
end
