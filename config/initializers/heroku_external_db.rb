if ENV['EXTERNAL_DATABASE_URL']
  HerokuExternalDb.setup_configuration!("USERS", "users")

  # This has to come last so that it will be the default ActiveRecord configuration.
  HerokuExternalDb.setup_rails_env!
end
