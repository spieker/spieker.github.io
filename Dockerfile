FROM ruby:2.3

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y -qq \
      libpq-dev

# Create app directory
ENV APP_HOME /usr/src/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy Gemfile
ADD Gemfile* $APP_HOME/

# Set Bundler cache directory outside of app scope
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2

# Fixing guard issues
RUN gem install bundler

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
