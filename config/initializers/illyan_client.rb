if ENV["ILLYAN_URL"] && ENV["ILLYAN_TOKEN"]
  IllyanClient.configure! do |client|
    client.base_url = ENV["ILLYAN_URL"]
    client.token = ENV["ILLYAN_TOKEN"]
  end
else
  puts "WARNING: Illyan client is not configured.  Inviting new users will not work.  "+
       "To configure the Illyan client, set the ILLYAN_URL and ILLYAN_TOKEN environment variables."
end
