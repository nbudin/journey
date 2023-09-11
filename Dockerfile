ARG RUBY_VERSION=2.6.10
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y libpq-dev imagemagick libmagickcore-dev git build-essential

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Move Docker database.yml into place
RUN mv config/database.yml.docker config/database.yml

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 DATABASE_URL=postgres://dummy/dummy ./bin/rake assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y libpq5 libmagickcore-6.q16-6 && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash
USER rails:rails

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0 -p $PORT
