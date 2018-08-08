FROM ruby:2.5.1

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs file imagemagick git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP /app
WORKDIR $APP

COPY Gemfile Gemfile.lock $APP/
RUN gem install bundler --conservative
RUN bundle install

COPY . $APP

COPY config/database.yml.template $APP/config/database.yml
COPY config/secrets.yml.template $APP/config/secrets.yml

RUN bundle exec rake db:setup
