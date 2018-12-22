ARG appdir=/app

FROM ruby:2.3.1-slim

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           build-essential \
           curl \
           file \
           git \
           gnupg \
           imagemagick \
           libmysqlclient-dev \
           libpq-dev \
           libsqlite3-dev \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           nodejs \
    && rm -rf /var/lib/apt/lists/*

ARG appdir
WORKDIR $appdir

COPY Gemfile Gemfile.lock $appdir/
RUN bundle install

CMD ["bash"]

