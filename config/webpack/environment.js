const path = require('path');
const { environment } = require('@rails/webpacker')

environment.config.merge({
  resolve: {
    alias: {
      '@rails': path.resolve(__dirname, '../../node_modules/@rails'),
    },
    modules: [
      path.resolve(__dirname, '../../node_modules'),
      'node_modules'
    ],
    extensions: ['.js', '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css', '.png', '.svg', '.gif', '.jpeg', '.jpg']
  }
});

environment.config.node = {
  __dirname: true,
  __filename: true,
  global: true
};

environment.config.set('stats', {
  errorDetails: true,
  warnings: false 
})

module.exports = environment
