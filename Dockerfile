FROM ruby:3.0.0
LABEL author="Austin Covrig <austinc@iiw.org>"
ENV HOME /app
ENV RAILS_ENV=production

EXPOSE 3000

CMD ["./docker_start.sh"]

RUN apt install -y curl gnupg \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash -
# TODO: make this not curl|bash, cuz that's *bad*

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential \
    liblzma-dev \
    graphviz \
    imagemagick \
    libmagickwand-dev \
    nodejs \
    patch \
    ruby-dev \
    zlib1g-dev \
    yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && mkdir /app

WORKDIR /app
ADD Gemfile /app
ADD Gemfile.lock /app
RUN bundle install

COPY . /app
RUN touch /app/.production
RUN SECRET_KEY_BASE=production bundle exec rake assets:precompile && bin/webpack

# HEALTHCHECK --start-period=60s --interval=10s CMD curl --fail -H 'Accept: application/json' http://localhost:3000 || exit 1