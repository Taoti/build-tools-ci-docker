FROM quay.io/pantheon-public/build-tools-ci:6.x
USER root

RUN npm install -g gulp-cli stylelint stylelint-no-browser-hacks stylelint-config-standard stylelint-order

RUN rm -rf /usr/local/share/terminus-plugins/terminus-build-tools-plugin
RUN git clone --branch=prepare-for-pantheon https://github.com/NickWilde1990/terminus-build-tools-plugin.git /usr/local/share/terminus-plugins/terminus-build-tools-plugin

# Remove hirak/prestismo (Composer 2 incompatible).
RUN composer -n global remove "hirak/prestissimo"
RUN composer self-update --2

#Add drupal-check for deprecation testing purposes.
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n global require --optimize-autoloader --sort-packages "mglaman/drupal-check:^1"
