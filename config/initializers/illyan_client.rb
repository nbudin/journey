require 'journey_config'

if JourneyConfig.config['illyan_url'] && JourneyConfig.config['illyan_token']
  IllyanClient.configure! do |client|
    client.base_url = JourneyConfig.config['illyan_url']
    client.token = JourneyConfig.config['illyan_token']
  end
else
  puts "WARNING: Illyan client is not configured.  Inviting new users will not work.  "+
       "To configure the Illyan client, set the ILLYAN_URL and ILLYAN_TOKEN environment variables."
end
