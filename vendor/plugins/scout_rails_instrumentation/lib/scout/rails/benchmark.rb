class << Benchmark
  if Rails::VERSION::STRING < '2.3.0'
    def ms
      1000 * realtime { yield }
    end
  end
end
