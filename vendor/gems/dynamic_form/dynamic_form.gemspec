Gem::Specification.new do |s|
  s.name = "dynamic_form"
  s.version = "1.1.4"
  s.authors = ["Joel Moss"]
  s.summary = "error_message_on and error_messages_for view helpers (vendored; see lib/dynamic_form.rb)"
  s.homepage = "https://github.com/joelmoss/dynamic_form"
  s.license = "MIT"
  s.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
  s.require_paths = ["lib"]
  s.add_dependency "rails", ">= 3.0"
end
