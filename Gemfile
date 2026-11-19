source "http://rubygems.org"
ruby "3.1.7"

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem "rails", "~> 6.1.7"
# concurrent-ruby 1.3.5+ no longer loads Logger, which Rails before 7.1 depends on
gem 'concurrent-ruby', '< 1.3.5'
gem 'will_paginate', '~> 3.3'
gem 'pg', '~> 1.5.9'
gem "jipe", ">= 2.0.1"
gem 'rollbar', '~> 2.27'
gem 'sequel'
# Vendored: unmaintained, and its ActiveModel::Errors override breaks on Ruby 3 (see vendor/gems/dynamic_form)
gem 'dynamic_form', path: 'vendor/gems/dynamic_form'
gem 'puma'
gem 'builder'
# Not used directly, but it bundles libxml2, so keep it current.  1.19+ requires Ruby 3.2.
gem 'nokogiri', '~> 1.18.0'
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
gem 'cancancan', '~> 3.0'
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
