const path = require('path');
const { environment } = require('@rails/webpacker');

const customConfig = {
  resolve: {
    fallback: {
      dgram: false,
      fs: false,
      net: false,
      tls: false,
      child_process: false
    }
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
            plugins: ['@babel/plugin-syntax-dynamic-import']
          }
        }
      }
    ]
  }
};

// 古いプロパティ削除の試みを取り除く
// environment.config.delete('node.dgram');
// environment.config.delete('node.fs');
// environment.config.delete('node.net');
// environment.config.delete('node.tls');
// environment.config.delete('node.child_process');

environment.config.merge(customConfig);

module.exports = environment.toWebpackConfig();
