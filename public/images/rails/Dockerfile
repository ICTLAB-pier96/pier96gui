FROM ruby:2.2


RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
RUN apt-get install -y libpq-dev
RUN bundle install

COPY . /usr/src/app

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

EXPOSE 3000
RUN rake db:setup
RUN rake db:migrate

CMD ["rails", "server", "-b", "0.0.0.0"]
