source "http://rubygems.org"
ruby "2.6.10"

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem "rails", "4.2.11.1"
gem 'will_paginate'
gem 'pg', '~> 0.20'
gem "jipe", ">= 2.0.1"
gem 'rollbar'
gem 'sequel'
gem 'dynamic_form'
gem 'puma'
gem 'breach-mitigation-rails'
gem 'builder'

gem 'prototype-rails', git: 'https://github.com/rails/prototype-rails.git', branch: '4.2'
gem 'tinymce-rails', '= 4.6.7'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'devise'
gem 'devise_cas_authenticatable'
gem 'cancancan'
gem 'illyan_client'
gem 'ae_users_migrator'

gem 'rack-ssl'

gem 'gruff', '~> 0.23.0'

group :test do
  gem "factory_girl_rails"
  gem "minitest-spec-rails"
  gem "minitest-reporters"
  gem "launchy"
  gem "database_cleaner"
  gem "capybara", ">= 2.0.0"
  gem "selenium-webdriver"
  gem "capybara_minitest_spec"
  gem "rails-dom-testing"
  gem "chromedriver-helper"
end

gem 'letter_opener_web', :group => :development
gem 'pry-rails', :groups => [:development, :test]

group :development do
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano-maintenance', '~> 1.0', require: false
  gem 'ed25519', require: false
  gem 'bcrypt_pbkdf', require: false
end
