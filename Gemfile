source "http://rubygems.org"
ruby "2.6.10"

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem "rails", "~> 5.2.8"
gem 'will_paginate'
gem 'pg', '~> 0.20'
gem "jipe", ">= 2.0.1"
gem 'rollbar'
gem 'sequel'
gem 'dynamic_form'
gem 'puma'
gem 'builder'
# to_xml/from_xml on models were extracted from Rails core in 5.0
gem 'activemodel-serializers-xml'

# Vendored: the upstream gem is unmaintained and requires Rails 4
gem 'prototype-rails', path: 'vendor/gems/prototype-rails'
gem 'tinymce-rails', '= 4.6.7'

group :assets do
  # Stay on the Ruby Sass compiler; sass-rails 6 switches to libsass, which could change the compiled CSS
  gem 'sass-rails', '~> 5.0'
  # Sass 3.5+ pulls in file-watcher gems (ffi) that don't support this Ruby
  gem 'sass', '~> 3.4.25'
end

gem 'devise'
gem 'devise_cas_authenticatable'
gem 'cancancan', '~> 2.3'
gem 'illyan_client'


gem 'gruff', '~> 0.23.0'

group :test do
  gem "factory_girl_rails"
  gem "minitest-spec-rails"
  # capybara_minitest_spec still uses the MiniTest constant, which was removed in minitest 5.19
  gem "minitest", "< 5.19"
  gem "minitest-reporters"
  gem "launchy"
  gem "simplecov", require: false
  gem "database_cleaner"
  gem "capybara", "~> 3.0"
  gem "selenium-webdriver", "~> 4.1"
  gem "capybara_minitest_spec"
  gem "rails-dom-testing"
  # assigns and assert_template were extracted from Rails core in 5.0
  gem "rails-controller-testing"
  gem "webdrivers", "~> 5.3"
end

gem 'letter_opener_web', :group => :development
gem 'pry-rails', :groups => [:development, :test]
