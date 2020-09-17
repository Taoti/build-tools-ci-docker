FROM quay.io/pantheon-public/build-tools-ci:6.x

RUN npm install -g gulp-cli stylelint stylelint-no-browser-hacks stylelint-config-standard stylelint-order

RUN rm -rf /usr/local/share/terminus-plugins/terminus-build-tools-plugin
RUN git clone --branch=prepare-for-pantheon https://github.com/NickWilde1990/terminus-build-tools-plugin.git /usr/local/share/terminus-plugins/terminus-build-tools-plugin

#Add drupal-check for deprecation testing purposes.
RUN curl -O -L https://github.com/mglaman/drupal-check/releases/download/1.0.14/drupal-check.phar
RUN mv drupal-check.phar /usr/local/bin/drupal-check
RUN chmod +x /usr/local/bin/drupal-check
