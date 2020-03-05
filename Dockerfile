# Use an official Python runtime as a parent image
FROM drupaldocker/php:7.2-cli
ARG DEBIAN_FRONTEND=noninteractive

###########################
# Install headless Chrome
# Borrowed from https://github.com/GoogleChrome/puppeteer/docs/troubleshooting.md#running-puppeteer-in-docker
###########################

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq gnupg2 libgconf-2-4

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/apt/sources.list.d/google-chrome-unstable.list \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init


###########################
# Install build tools things
###########################

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby jq curl apt-utils apt-transport-https ca-certificates
RUN gem install circle-cli
RUN composer -n global require -n "hirak/prestissimo:^0.3"

# Install NPM
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb https://deb.nodesource.com/node_10.x stretch main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src https://deb.nodesource.com/node_10.x stretch main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install gcc g++ make nodejs -y
RUN npm install -g gulp-cli stylelint stylelint-no-browser-hacks stylelint-config-standard stylelint-order

# Create an unpriviliged testuser
RUN groupadd -g 999 tester && \
    useradd -r -m -u 999 -g tester tester && \
    chown -R tester /usr/local && \
    chown -R tester /build-tools-ci
USER tester

RUN mkdir -p /usr/local/share/terminus
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus:"^2"

RUN mkdir -p /usr/local/share/clu
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/clu require danielbachhuber/composer-lock-updater:^0.5.0

RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^8"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Add a collection of useful Terminus plugins
env TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins
RUN mkdir -p /usr/local/share/terminus-plugins
RUN git clone --branch=prepare-for-pantheon https://github.com/NickWilde1990/terminus-build-tools-plugin.git /usr/local/share/terminus-plugins/terminus-build-tools-plugin
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1.3
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-rsync-plugin:^1.1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-quicksilver-plugin:^1.3
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-composer-plugin:^1.1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-drupal-console-plugin:^1.1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-mass-update:^1.1
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-aliases-plugin:^1.2
# TODO: Re-add the site clone plugin once it has been updated to work with Terminus 2
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-site-clone-plugin:^2

# Add hub in case anyone wants to automate GitHub PR creation, etc.
#RUN curl -LO https://github.com/github/hub/releases/download/v2.11.2/hub-linux-amd64-2.11.2.tgz && tar xzvf hub-linux-amd64-2.11.2.tgz && ln -s /build-tools-ci/hub-linux-amd64-2.11.2/bin/hub /usr/local/bin/hub

# Add lab in case anyone wants to automate GitLab MR creation, etc.
#RUN curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | bash

# Add phpcs for use in checking code style
RUN mkdir ~/phpcs && cd ~/phpcs && COMPOSER_BIN_DIR=/usr/local/bin composer require squizlabs/php_codesniffer:^2.7

# Add phpunit for unit testing
RUN mkdir ~/phpunit && cd ~/phpunit && COMPOSER_BIN_DIR=/usr/local/bin composer require phpunit/phpunit:^6

# Add bats for functional testing
RUN git clone https://github.com/sstephenson/bats.git; bats/install.sh /usr/local

#Add drupal-check for deprecation testing purposes.
RUN curl -O -L https://github.com/mglaman/drupal-check/releases/download/1.0.14/drupal-check.phar
RUN mv drupal-check.phar /usr/local/bin/drupal-check
RUN chmod +x /usr/local/bin/drupal-check

ENTRYPOINT ["dumb-init", "--"]
