require 'journey_config'

Rails.application.config.session_store :cookie_store, :key => '_journey_aegames_org-trunk_session'
Rails.application.config.secret_token = JourneyConfig.config['secret_token'] || 'ca837e0d9bfed2129139ac1712cf768687981f043aca55c15b424d1deee830babca9bf84afea63d9fd18164f9b026b5c5846b3cb1d64d8febeab9618d24a385f'
