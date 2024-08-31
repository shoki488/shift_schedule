const { environment } = require('@rails/webpacker');

environment.config.node = {
  __dirname: true,
  __filename: true,
  global: true
};

module.exports = environment;
