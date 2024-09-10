const path = require('path');
const { environment } = require('@rails/webpacker')

environment.config.merge({
  resolve: {
    fallback: {
     "domain": require.resolve("domain-browser")
    },
    alias: {
      '@rails': path.resolve(__dirname, '../../node_modules/@rails'),
    },
    modules: [
      'node_modules',
      path.resolve(__dirname, '../../node_modules')
    ]
  }
});

environment.config.node = {
  __dirname: true,
  __filename: true,
  global: true
};

module.exports = environment
