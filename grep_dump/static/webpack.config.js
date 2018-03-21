// reminder: each section below has a section here: https://webpack.js.org/concepts/
// const path = require('path');

module.exports = {

  entry: {
    pagePurpleRanger: './src/index.jsx',  // #pending-rename
    pageBlueRanger: './src/blue-ranger.jsx',
  },

  output: {
    filename: '[name].js',  // per [..].org/concepts/output
    path: __dirname + '/dist',
  },

  resolve: {
    extensions: ['.js', '.jsx', '.css'],
  },

  module: {
    rules: [
      {
        test: /\.jsx?/,
        exclude: /node_modules/,
        use: 'babel-loader',
      },
    ],
  }
};
