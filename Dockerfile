FROM alpine:3.5

ENV BUILD_PKGS="build-base ruby-dev libffi-dev libxml2-dev mariadb-dev" \
    RUNTIME_PKGS="ruby ruby-json ruby-bigdecimal ruby-irb ruby-bundler ca-certificates mariadb-client" \

RUN mkdir /srv/app
WORKDIR /srv/app
COPY . ./

RUN apk --no-cache add $RUNTIME_PKGS && \
    apk --no-cache add --virtual .build-dependencies $BUILD_PKGS && \
    bundle install --without development --jobs 4 && \
    apk del .build-dependencies

RUN bundle exec rake assets:precompile RAILS_ENV=test

# Make tmp/log dirs writable for app user
RUN chown nobody tmp log public/uploads

# Run app as unpriviledged user
USER nobody

EXPOSE 3000

CMD ["rails", "server", "--bind", "0.0.0.0"]
