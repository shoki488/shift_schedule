const { environment } = require('@rails/webpacker');

environment.config.node = {
  __dirname: true,
  __filename: true,
  global: true
};
environment.config.resolve.alias['@hotwired'] = 'node_modules/@hotwired'
module.exports = environment;
