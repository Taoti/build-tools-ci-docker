# Docker Build Tools CI

[![docker pull quay.io/taoticreative/build-tools-ci-docker](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/taoticreative/build-tools-ci-docker)

This is the source Dockerfile for the [Taoti build tools docker image](https://quay.io/repository/taoticreative/build-tools-ci-docker) and is based of off the [pantheon-public/build-tools-ci](https://quay.io/repository/pantheon-public/build-tools-ci) docker image, primary changes are the addition of NPM and Gulp.

## Image Contents

- [Drupal PHP 7.3 Docker base image](https://github.com/drupal-docker/php/tree/2.x/7.3)
- [Terminus](https://github.com/pantheon-systems/terminus)
- Terminus plugins
  - [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin)
  - [Terminus Secrets Plugin](https://github.com/pantheon-systems/terminus-secrets-plugin)
  - [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync)
  - [Terminus Quicksilver Plugin](https://github.com/pantheon-systems/terminus-quicksilver-plugin)
  - [Terminus Composer Plugin](https://github.com/pantheon-systems/terminus-composer-plugin)
  - [Terminus Drupal Console Plugin](https://github.com/pantheon-systems/terminus-drupal-console-plugin)
  - [Terminus Mass Update Plugin](https://github.com/pantheon-systems/terminus-mass-update)
  - [Terminus Aliases Plugin](https://github.com/pantheon-systems/terminus-aliases-plugin)
- Test tools
  - headless chrome
  - phpunit
  - bats
  - behat
  - php_codesniffer
  - hub
  - lab
- Test scripts
- NPM
- Gulp
