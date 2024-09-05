const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

environment.plugins.append(
    'Provide',
    new webpack.ProvidePlugin({
      Rails: '@rails/ujs',
      ActiveStorage: '@rails/activestorage'
    })
  );
module.exports = environment;
