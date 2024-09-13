const { environment } = require('@rails/webpacker')
const path = require('path')

module.exports = {
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  entry: './app/javascript/packs/application.js',
  output: {
    filename: 'js/[name]-[contenthash].js',
    path: path.resolve(__dirname, 'public/packs'),
    publicPath: '/packs/'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  },
  resolve: {
    extensions: ['.js', '.jsx']
  },
  node: {
    __dirname: true,
    __filename: true,
    global: true
  }
};
