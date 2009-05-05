require File.join(File.dirname(__FILE__), '..', 'scout')
require File.join(File.dirname(__FILE__), 'rails', 'benchmark')
require File.join(File.dirname(__FILE__), 'rails', 'instrumentation')
require File.join(File.dirname(__FILE__), 'rails', 'explains')
require File.join(File.dirname(__FILE__), 'rails', 'x-runtime_fix') if Rails::VERSION::STRING < "2.0.0"
