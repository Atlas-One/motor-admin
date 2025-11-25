FROM ruby:3.2.0-alpine

ENV RAILS_ENV=development
ENV NODE_ENV=development

WORKDIR /opt/motor-admin

# Install system dependencies
RUN apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base \
    python3 \
    freetds-dev \
    sqlite-dev \
    libpq-dev \
    mariadb-dev \
    tzdata

# Install bundler
RUN gem install bundler

# Copy dependency files
COPY ./Gemfile ./Gemfile.lock ./
COPY ./package.json ./yarn.lock ./
COPY ./vendor/motor-admin/lib/motor/version.rb ./vendor/motor-admin/lib/motor/version.rb
COPY ./vendor/motor-admin/motor-admin.gemspec ./vendor/motor-admin/motor-admin.gemspec

# Install Ruby dependencies
RUN bundle install

# Install Node dependencies for main app
RUN yarn install --network-timeout 1000000

# Copy application code
COPY . ./

# Build Motor Admin UI assets
WORKDIR /opt/motor-admin/vendor/motor-admin/ui
RUN yarn install --network-timeout 1000000 && yarn build:prod

# Return to app directory
WORKDIR /opt/motor-admin

# Expose ports
EXPOSE 3001 3035

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]
