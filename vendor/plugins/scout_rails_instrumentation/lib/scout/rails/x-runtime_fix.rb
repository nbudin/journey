class ActionController::Base
  def perform_action_with_x_runtime
    unless logger
      perform_action_without_x_runtime
    else
      runtime = [Benchmark::measure{ perform_action_without_x_runtime }.real, 0.0001].max
      response.headers["X-Runtime"] = "%.5f" % runtime
    end
  end
  alias_method_chain :perform_action, :x_runtime
end
