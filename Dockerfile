# syntax=docker/dockerfile:1

# --- Builder stage ---
FROM ruby:3.1.0 AS builder

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "development test" && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN bundle exec rake assets:precompile SECRET_KEY_BASE_DUMMY=1

# --- Runtime stage ---
FROM ruby:3.1.0-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

RUN chmod +x bin/docker-entrypoint

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
