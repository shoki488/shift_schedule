process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.config.node = {
    __dirname: false,
    __filename: false,
    global: false
  }

module.exports = environment.toWebpackConfig()
