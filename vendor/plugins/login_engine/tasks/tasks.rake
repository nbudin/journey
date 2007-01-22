desc 'Import the login engine schema'
task :import_login_engine_schema => :environment do
  load "#{Engines.get(:login).root}/db/schema.rb"
end