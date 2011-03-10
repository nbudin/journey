source "http://rubygems.org"

puts ENV.inspect

gem 'bundler'
gem "rails", "2.3.5"
gem 'fastercsv', :platforms => "ruby_18"
gem 'paginator'
gem 'will_paginate'
gem "mysql"
gem "ruby-openid", :require => "openid"
gem "xebec", "2.6.0"
gem 'ae_users_legacy', '0.6.3', :require => 'ae_users'
gem "heroku_external_db", ">= 1.0.0"

gem 'rmagick4j', :require => "RMagick", :platforms => 'jruby'
gem 'rmagick', "~> 2.11", :require => 'RMagick', :platforms => ['ruby', 'mswin']
gem 'gruff', '~> 0.3.6'

if ENV["SUGARPOND_USERNAME"] && ENV["SUGARPOND_PASSWORD"]
  puts "Detected Sugar Pond username and password in environment, will add Sugar Pond gems"
  
  source "http://#{ENV["SUGARPOND_USERNAME"]}:#{ENV["SUGARPOND_PASSWORD"]}@gems.sugarpond.net"
  gem 'journey_sugarpond_branding', "1.0.0"
  gem 'journey_paywall', "1.0.0"
end

group :test do
  gem "factory_girl"
  gem "shoulda"
  gem "cucumber-rails"
  gem "launchy"
  gem "database_cleaner", ">= 0.5.0"
  gem "capybara", ">= 0.3.5"
end