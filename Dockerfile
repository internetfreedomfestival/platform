ARG appdir=/app

FROM ruby:2.5.1

RUN set -ex \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -f -y --no-install-recommends \
           nodejs \
    && rm -rf /var/lib/apt/lists/*

ARG appdir
WORKDIR $appdir

COPY Gemfile Gemfile.lock $appdir/
RUN bundle install

CMD ["bash"]

