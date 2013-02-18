require 'journey_config'

Airbrake.configure do |config|
  config.api_key = JourneyConfig.config['airbrake_api_key']
  config.host    = JourneyConfig.config['airbrake_host']
end
