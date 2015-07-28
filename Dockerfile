FROM ruby:2.1.6

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
    mysql-client nodejs && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --jobs 4

COPY . /usr/src/app

EXPOSE 3000

CMD ["rails", "server", "--binding", "0.0.0.0"]
