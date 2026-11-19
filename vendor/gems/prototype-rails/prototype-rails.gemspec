Gem::Specification.new do |spec|
  spec.name     = 'prototype-rails'
  spec.version  = '4.0.0'
  spec.summary  = 'Prototype, Scriptaculous, and RJS for Ruby on Rails'
  spec.homepage = 'http://github.com/rails/prototype-rails'
  spec.author   = 'Xavier Noria'
  spec.email    = 'fxn@hashref.com'

  spec.files = %w(README.md MIT-LICENSE) + Dir['lib/**/*', 'vendor/**/*', 'test/**/*']

  # Vendored from https://github.com/rails/prototype-rails (4.2 branch, commit 0fed929), which is no longer
  # maintained.  The Rails constraint is relaxed so that this app can keep using these helpers while upgrading.
  spec.add_dependency('rails', '>= 4.0', '< 7')
  spec.license = "MIT"
end
