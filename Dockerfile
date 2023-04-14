from ruby:2.6.2

run apt-get update && apt-get install -y libpq-dev graphicsmagick-libmagick-dev-compat libmagickwand-dev imagemagick

add . /app
run cp /app/config/database.yml.docker /app/config/database.yml
run cd /app ; gem install nokogiri --platform=ruby ; bundle install --without development test

env RAILS_ENV production
expose 3000
cmd ["ruby", "/app/script/rails", "server", "-p", "3000"]
