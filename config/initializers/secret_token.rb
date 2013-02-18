token_file = File.expand_path('../../secret_token.yml', __FILE__)

secret_token = if File.exists? token_file
  YAML.load(File.read(token_file))["secret_token"]
else
  ENV['SECRET_TOKEN'] || 'ca837e0d9bfed2129139ac1712cf768687981f043aca55c15b424d1deee830babca9bf84afea63d9fd18164f9b026b5c5846b3cb1d64d8febeab9618d24a385f'
end

config.action_controller.session = {
    :key         => '_journey_aegames_org-trunk_session',
    :secret      => secret_token,
    :expire_after => 2.weeks
  }