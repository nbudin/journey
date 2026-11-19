source "http://rubygems.org"
ruby "3.4.9"

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem "rails", "~> 8.1.0"
gem 'will_paginate', '~> 3.3'
gem 'pg', '~> 1.5.9'
gem "jipe", ">= 2.0.1"
gem 'rollbar', '~> 3.5'
gem 'sequel'
# Vendored: unmaintained, and its ActiveModel::Errors override breaks on Ruby 3 (see vendor/gems/dynamic_form)
gem 'dynamic_form', path: 'vendor/gems/dynamic_form'
gem 'puma'
gem 'builder'
# Rails 7.1 pulls in psych via irb and rdoc.  psych 5 needs libyaml headers to compile, which the Docker base image
# doesn't have; the psych that ships with this Ruby needs nothing extra.
gem 'psych', '~> 4.0'
# rmagick and factory_girl require 'observer', which stopped being a default gem in Ruby 3.4
gem 'observer'
# CSV left the default gems in Ruby 3.4 (used by ResponsesCsvExporter)
gem 'csv'
# ActiveSupport's default XML backend (XML request/response handling); Rails doesn't declare it, and it used to arrive only via selenium
gem 'rexml'
# Not used directly, but it bundles libxml2, so keep it current.  1.19+ requires Ruby 3.2.
gem 'nokogiri', '~> 1.19.5'
# to_xml/from_xml on models were extracted from Rails core in 5.0
gem 'activemodel-serializers-xml'

# Vendored: the upstream gem is unmaintained and requires Rails 4
gem 'prototype-rails', path: 'vendor/gems/prototype-rails'
gem 'tinymce-rails', '= 4.9.11.1'

# Sprockets 4 with the current (Dart) Sass compiler
gem 'dartsass-sprockets'
gem 'sprockets', '~> 4.2'

gem 'devise', '~> 4.9.4'
gem 'devise_cas_authenticatable'
gem 'cancancan', '~> 3.0'
gem 'illyan_client'


gem 'gruff', '~> 0.23.0'

group :test do
  gem "factory_girl_rails"
  gem "minitest-spec-rails"
  gem "minitest", "~> 5.25"
  gem "minitest-reporters"
  gem "launchy"
  gem "simplecov", require: false
  gem "database_cleaner"
  gem "capybara", "~> 3.0"
  gem "selenium-webdriver", "~> 4.14"
  # Loaded from test_helper, after the MiniTest alias it needs (minitest 5.19+ no longer defines it)
  gem "capybara_minitest_spec", require: false
  gem "rails-dom-testing"
  # assigns and assert_template were extracted from Rails core in 5.0
  gem "rails-controller-testing"
end

gem 'letter_opener_web', :group => :development
gem 'pry-rails', :groups => [:development, :test]
