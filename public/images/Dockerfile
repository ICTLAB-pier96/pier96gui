FROM ruby:2.2


RUN mkdir -p /usr/src
WORKDIR /usr/src

RUN git clone https://github.com/ICTLAB-pier96/pier96gui.git app

RUN apt-get update
RUN apt-get install -y libpq-dev
RUN apt-get install -y cron

WORKDIR /usr/src/app

RUN bundle install
RUN whenever --update-crontab store

RUN echo Europe/Amsterdam | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata



RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

EXPOSE 3000
RUN rake db:migrate

ADD start /start
CMD /start

