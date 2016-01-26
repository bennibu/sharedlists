FROM aboutsource/ruby-extras:2.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --jobs 4

COPY . /usr/src/app

EXPOSE 3000

CMD ["rails", "server", "--binding", "0.0.0.0"]
