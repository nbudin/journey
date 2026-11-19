require 'test_helper'

class RailsSequelTest < ActiveSupport::TestCase
  after { RailsSequel.reset_config! }

  def with_config(config)
    RailsSequel.instance_variable_set(:@config, config.with_indifferent_access)
    RailsSequel.prepare_options
  end

  it "connects to the same database as ActiveRecord" do
    db = RailsSequel.connect
    begin
      assert_equal ActiveRecord::Base.connection.current_database, db.fetch("select current_database() as name").first[:name]
    ensure
      db.disconnect
    end
  end

  it "translates a database.yml configuration into Sequel options" do
    options = with_config(adapter: "postgresql", host: "db.example.com", username: "me", password: "secret", database: "journey", sslmode: "require")

    assert_equal "postgresql", options[:adapter]
    assert_equal "db.example.com", options[:host]
    assert_equal "me", options[:user]
    assert_equal "secret", options[:password]
    assert_equal "journey", options[:database]
    assert_equal "require", options[:sslmode]
    assert_equal [Rails.logger], options[:loggers]
  end

  it "applies defaults for anything missing" do
    options = with_config(adapter: "postgresql")

    assert_equal "localhost", options[:host]
    assert_equal "", options[:user]
    assert_equal "utf8", options[:encoding]
    assert_equal "hey_dude_configure_your_database", options[:database]
  end

  it "maps the sqlite3 adapter name to Sequel's" do
    assert_equal "sqlite", with_config(adapter: "sqlite3")[:adapter]
  end

  it "passes driver options through" do
    assert_equal({ options: "-c search_path=foo" }, with_config(adapter: "postgresql", options: "-c search_path=foo")[:driver_options])
  end

  it "supports connecting by URL" do
    assert_equal "postgres://u:p@host/db", with_config(adapter: "postgresql", url: "postgres://u:p@host/db")[:url]
  end
end
