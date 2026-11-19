require 'test_helper'
require 'erb'
require 'yaml'

# config/database.yml.docker becomes config/database.yml in the Docker image, building the connection settings
# from DATABASE_URL.  Rails 6 rejects an empty configuration, which this template once produced without anyone
# noticing (its attribute lines were accidentally YAML comments).
class DatabaseYmlDockerTest < ActiveSupport::TestCase
  def render(url, env = "production")
    saved = ENV.to_h.slice("DATABASE_URL", "RAILS_ENV", "RACK_ENV")
    ENV["DATABASE_URL"] = url
    ENV["RAILS_ENV"] = env
    YAML.load(ERB.new(File.read(Rails.root.join("config", "database.yml.docker"))).result)
  ensure
    %w(DATABASE_URL RAILS_ENV RACK_ENV).each { |key| saved.key?(key) ? ENV[key] = saved[key] : ENV.delete(key) }
  end

  it "builds the connection settings from DATABASE_URL" do
    config = render("postgres://appuser:s3cret@db.example.com:5432/appdb?sslmode=require")["production"]

    assert_equal "postgresql", config["adapter"]
    assert_equal "appdb", config["database"]
    assert_equal "appuser", config["username"]
    assert_equal "s3cret", config["password"]
    assert_equal "db.example.com", config["host"]
    assert_equal 5432, config["port"]
    assert_equal "require", config["sslmode"]
  end

  it "is a valid, non-empty configuration even for a minimal URL (as used when building the image)" do
    config = render("postgres://dummy/dummy")["production"]

    assert_kind_of Hash, config
    assert_equal({ "adapter" => "postgresql", "database" => "dummy", "host" => "dummy" }, config)
  end

  it "uses the current environment's name" do
    assert_equal ["staging"], render("postgres://dummy/dummy", "staging").keys
  end
end
