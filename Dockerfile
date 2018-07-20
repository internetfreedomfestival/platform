FROM ruby:2.5

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

ENV APP /app
WORKDIR $APP

COPY . $APP

COPY config/database.yml.template $APP/config/database.yml
COPY config/secrets.yml.template $APP/config/secrets.yml

RUN bin/setup
