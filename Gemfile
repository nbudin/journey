source "http://rubygems.org"

gem 'bundler'
gem "rails", "2.3.5"
gem 'fastercsv' if RUBY_VERSION < "1.9"
gem 'paginator'
gem 'will_paginate'
gem "mysql"
gem "ruby-openid", :require => "openid"
gem "xebec", "2.6.0"

if RUBY_PLATFORM =~ /java/
  gem 'rmagick4j', :require => "RMagick"
else
  gem 'rmagick', "~> 2.11", :require => 'RMagick'
end

gem 'gruff', '~> 0.3.6'

gem "google4r-checkout", "1.1.beta2"

group :test do
  gem "factory_girl"
  gem "shoulda"
  gem "cucumber-rails"
  gem "launchy"
  gem "database_cleaner", ">= 0.5.0"
  gem "capybara", ">= 0.3.5"
end
