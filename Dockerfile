ARG RUBY_VERSION=2.6.10
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development"

# Debian 11 (bullseye) is end of life and its packages have moved to archive.debian.org; the regular
# mirrors now return 404 for them, so point apt at the archive or no image build can install packages.
RUN printf '%s\n' \
    'deb http://archive.debian.org/debian bullseye main' \
    'deb http://archive.debian.org/debian-security bullseye-security main' \
    > /etc/apt/sources.list && \
  echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive


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

# Distrust the two roots affected by the 20 Oct 2026 eMudhra intermediate CA compromise
# (https://emudhra.we-have-a-problem.com/). This image is Debian 11 (Ruby 2.6.10), which no longer
# gets ca-certificates updates, so apply the advisory's manual workaround instead.
RUN sed -i \
    -e 's|^mozilla/emSign_ECC_Root_CA_-_G3.crt|!&|' \
    -e 's|^mozilla/Comodo_AAA_Services_root.crt|!&|' \
    /etc/ca-certificates.conf && \
  update-ca-certificates

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash
USER rails:rails

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0 -p $PORT
