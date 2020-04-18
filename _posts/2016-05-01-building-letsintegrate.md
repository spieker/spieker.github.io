---
layout: post
title:  "Building Let's integrate! - The Ruby on Rails API"
date:   2016-05-01 10:00:00 +0000
categories: api
image:  /images/bg.jpg
---
Most likely you have already heard about the so called "refugee crisis" in
Europe. A couple of Friends (germans and refugees) and I started a project
to bring locals and refugees together. It's an internet platform based on Ruby
on Rails, and in this post I'm going to show you how I usually start a new Rails
project.

## My *not so* secret love

It's now about half a year ago when I fell in love again. We didn't have an easy
start but I don't want to miss Docker anymore. Not only for production use, but
more importantly for development! So, we are going to use it for
[Let's integrate!](https://letsintegrate.com) as well.


## A quick start

Without going into to much details, I'll quickly walk you through the setup of
the API. As I already said, I love Docker and I dislike messing up my system, so
I use Docker for setting up the project as well.

    docker run -v $PWD:/usr/src/app -w /usr/src/app rails:4 rails new \
      --database=postgresql --skip-bundle --skip-sprockets --skip-spring \
      --skip-javascript --skip-turbolinks -T letsintegrate

Here, I use the `rails` image of Docker with the version tag `4` to run the
`rails new` command. Also I use PostgreSQL, skip `bundle install`, Sprockets,
Spring, JavaScript, Turbolinks and Tests.

It makes no sense to run `bundle install`, since the container created for
running the `rails new` command is temporary and will be destroyed afterwards.
We don't need Sprockets, JavaScript and Turbolinks for an API,and  Spring is not
working properly with Docker yet. The test setup is skipped, since we're going
to use RSpec.

### Let's dockerize it

For Rails projects, I usually use a similar Dockerfile. It's using the `ruby`
base image, installs the PostgreSQL headers, installs the Gems and adds the
application.

~~~dockerfile
# Dockerfile
FROM ruby:2.3

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y -qq \
      libpq-dev

# Create app directory
ENV APP_HOME /usr/src/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Set Bundler cache directory outside of app scope
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2

# Fixing guard issues
RUN gem install bundler

# Copy Gemfile
ADD Gemfile* $APP_HOME/

# Install gems
RUN bundle install

# Copy working directory
ADD . $APP_HOME

# Add bin/ folder to PATH
ENV PATH $APP_HOME/bin:$PATH

# Create tmp directory
RUN mkdir $APP_HOME/tmp && \
    mkdir $APP_HOME/tmp/pids \
    mkdir $APP_HOME/log
~~~

Before we build the image, some files could be ignored so they don't become part
of the image.

~~~
# .dockerignore
.git
.dockerignore
Dockerfile
tmp
coverage
doc
log
~~~

And finally we create a Docker Compose file to spin up our development
environment.

~~~yaml
# docker-compose.yml
db:
  image: postgres:9.4.1
  ports:
    - "5432:5432"

web:
  build: .
  command: rails server --port 3000 --binding 0.0.0.0
  ports:
    - "3000:3000"
  links:
    - db
  volumes:
    - .:/usr/src/app
  volumes_from:
    - bundle

bundle:
  image: letsintegrate_web
  command: echo "I'm a little data container, short and stout..."
  volumes:
    - /usr/local/bundle
~~~

Before building the images now, there is one last thing to do. We need to make
sure, the images are named correctly so they match the name in the
`docker-compose.yml` (in this case `letsintegrate_web`). Docker Compose is using
the project name, which defaults to the folder name, as image name and adds the
service name when building it. To overwrite the project name, the environment
variable `COMPOSE_PROJECT_NAME` can be set. To do this, I use
[direnv](http://direnv.net/). The `.envrc` file in the project root contains the
export statement for the variable.

~~~
export COMPOSE_PROJECT_NAME=letsintegrate
~~~

### ... and now the Rails part

After running `docker-compose build`, a working image exists but the Rails part
still needs to be taken care of. Every service runs in its own container. These
containers are linked and can be referenced by it's names. The database settings
of the project have to be adjusted to reference the hostname of the linked
database container (in this case `db`).

~~~yaml
default: &default
  adapter:  postgresql
  encoding: unicode
  host:     db
  username: postgres
  pool:     5

development:
  <<: *default
  database: letsintegrate_development

test:
  <<: *default
  database: letsintegrate_test
~~~

With this done, let's create the database.

    docker-compose run web rake db:create

Hurray!
