source "http://rubygems.org"

gem "rails", "~> 2.3.5"
gem 'fastercsv' if RUBY_VERSION < "1.9"
gem 'paginator'
gem 'will_paginate'
gem "mysql"
gem "ruby-openid", :require => "openid"

if RUBY_PLATFORM =~ /java/
  gem 'rmagick4j', :require => "RMagick"
else
  gem 'rmagick', :require => 'RMagick'
end

gem 'gruff', '~> 0.3.6'

gem "nbudin-google4r-checkout", "~> 1.0.11"

group :test do
  gem "shoulda"
end