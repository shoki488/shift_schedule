const { environment } = require('@rails/webpacker')
const path = require('path')

environment.config.merge({
  resolve: {
    alias: {
      '@hotwired': path.resolve(__dirname, '../../node_modules/@hotwired')
    }
  }
})

module.exports = environment
