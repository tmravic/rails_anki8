FROM ruby:3.3.6-slim

# Install minimal dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    git \
    apache2 \
    apache2-dev \
    libcurl4-openssl-dev \
    && curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install bundler and Passenger
RUN gem install bundler -v 2.3.26 --no-document && \
    gem install passenger -v 6.0.27 --no-document && \
    passenger-install-apache2-module --auto

# Copy Apache configuration files
COPY conf.d/passenger.conf /etc/apache2/mods-available/passenger.conf
COPY conf.d/rails_anki8.conf /etc/apache2/sites-available/rails_anki8.conf
COPY conf.d/apache2.conf /etc/apache2/apache2.conf

CMD ["bash"]

## Enable Apache modules and site
#RUN a2enmod passenger rewrite && \
#    a2ensite rails_anki8 && \
#    a2dissite 000-default
#
## Set working directory and copy app
#WORKDIR /myapp
#COPY . .
#
## Install app dependencies
#ENV BUNDLE_WITHOUT=development:test
#RUN bundle install --without development test && \
#    yarn install --production
#
## Precompile assets
#ENV RAILS_ENV=production \
#    SECRET_KEY_BASE=5db0e2382250d80ae1bc8767501d403ee4ce0ebd7d331d070ddd9306befd71d3ff531b75d04601c5fc2088a557635161133047c6ac23a3146cb898a9f8826e4b
#RUN bundle exec rails assets:precompile
#
## Fix permissions for Apache user
#RUN chown -R www-data:www-data /myapp && \
#    chmod -R 755 /myapp
#
## Expose port
#EXPOSE 80
#
## Start Apache
#CMD ["apache2ctl", "-D", "FOREGROUND"]