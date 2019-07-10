# Use Pantheon image as base.
FROM pantheon-public/build-tools-ci:5.x

# Install NPM
# With the horrible pattern of curl [] | sudo!
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install nodejs -y
RUN npm install -g grunt-cli
