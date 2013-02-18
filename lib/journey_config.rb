class JourneyConfig
  def self.config
    @config ||= JourneyConfig.new
  end
  
  def initialize
    @config = {}
    
    config_file = File.join(Rails.root, 'config', 'journey.yml')
    @config.merge YAML.load(File.read(config_file)) if File.exists?(config_file)
  end
  
  def [](key)
    @config[key.downcase] || ENV[key.upcase]
  end
end