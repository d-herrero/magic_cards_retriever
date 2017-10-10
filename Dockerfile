# Ruby Alpine variant as it is lighter and enough for a simple script as this one.
# https://hub.docker.com/_/ruby/
FROM ruby:2.4.2-alpine3.6

LABEL maintainer "Daniel Herrero <daniel.herrero.101@gmail.com>"

ENV INSTALL_PATH /magic_cards_retriever

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./

RUN bundle install --binstubs

COPY . .

VOLUME ["$INSTALL_PATH/public"]
