FROM ruby:2.7.2-alpine

ENV TZ America/Sao_Paulo
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV RUBYOPT -W0

ENV WORKDIR app/
WORKDIR $WORKDIR

COPY Gemfile ./
COPY Gemfile.lock ./
COPY state_machine.gemspec ./
COPY lib/state_machine/version.rb ./lib/state_machine/version.rb

ARG BUILD_PACKAGES="build-base g++ gcc make"
RUN gem install bundler && \
    apk update && \
    apk add --update --no-cache ${BUILD_PACKAGES} git graphviz ttf-freefont &&\
    bundle install && \
    bundle config --global --jobs `expr $(grep processor /proc/cpuinfo | wc -l) - 1` && \
    apk del ${BUILD_PACKAGES} && \
    rm -r /var/cache/apk/*

COPY . .

CMD ["./bin/console"]
