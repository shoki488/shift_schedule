const { environment } = require('@rails/webpacker')
const path = require('path')

environment.config.node = {
  __dirname: true,
  __filename: true,
  global: true
}

environment.config.resolve.alias['@hotwired'] = path.resolve(__dirname, '../../node_modules/@hotwired')

module.exports = environment
