var merge = require('webpack-merge');
var webpack = require('webpack');
var autoprefixer = require('autoprefixer');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');
var FaviconsWebpackPlugin = require('favicons-webpack-plugin');

var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'prod' : 'dev';

var DEBUG = process.argv.indexOf('--debug') !== -1;

var commonConfig = {

  entry: './src/app/app.js',

  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.elm']
  },

  module: {
    loaders: [
      { test: /\.woff2?$/, use: "url-loader?limit=10000&mimetype=application/font-woff" },
      { test: /\.ttf$/,  use: "url-loader?limit=10000&mimetype=application/octet-stream" },
      { test: /\.eot$/,  use: "file-loader" },
      { test: /\.svg$/,  use: "url-loader?limit=10000&mimetype=image/svg+xml" },
      { test: /\.(png|jpg|jpeg|gif|woff)$/, use: 'url-loader?limit=8192' }
    ],

    noParse: [/\.elm$/]
  },

  plugins: [
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: './src/index.html',
      minify: {
        collapseBooleanAttributes: true,
        collapseWhitespace: true,
        decodeEntities: true,
        html5: true,
        minifyCSS: true,
        minifyJS: true,
        processConditionalComments: true,
        removeAttributeQuotes: true,
        removeComments: true,
        removeEmptyAttributes: true,
        removeOptionalTags: true,
        removeRedundantAttributes: true,
        removeScriptTypeAttributes: true,
        removeStyleLinkTypeAttributes: true,
        removeTagWhitespace: true,
        sortAttributes: true,
        sortClassName: true,
        useShortDoctype: true
      }
    }),
  ],
};

styleLoaders = [
  'style-loader',
  'css-loader?sourceMap',
  {
    loader: 'postcss-loader',
    options: {
      sourceMap: true,
      plugins: [
        autoprefixer({browsers: ['last 2 versions']})
      ]
    }
  },
  'sass-loader?sourceMap'
];

elmDebugArg = DEBUG ? '&debug=true' : '';

if (TARGET_ENV === 'dev') {
  module.exports = merge(commonConfig, {
    output: {
      path: __dirname + '/build',
      filename: 'app.js'
    },

    devServer: {
      inline: true,
      historyApiFallback: true,
      noInfo: true,
      watchOptions: {
        aggregateTimeout: 300,
        poll: 1000
      },
      stats: {
        colors: true
      }
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            'elm-hot-loader',
            'elm-webpack-loader?verbose=true&warn=true' + elmDebugArg
          ]
        },
        {
          test: /\.(css|scss)$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: styleLoaders
        }
      ]
    }
  });
}

if (TARGET_ENV === 'prod') {
  module.exports = merge(commonConfig, {
    plugins: [
      new webpack.optimize.UglifyJsPlugin({
        minimize: true,
        compressor: {warnings: false},
        mangle: true
      }),
      new ExtractTextPlugin('/styles-[contenthash].css'),
      new ProgressBarPlugin({
        renderThrottle: 500
      }),
      new FaviconsWebpackPlugin({
        logo: './src/images/monzo.svg',
        prefix: 'icons-[hash]/',
        background: '#16243b',
        title: 'Monzo Web',
        icons: {
          android: true,
          appleIcon: true,
          appleStartup: false,
          favicons: true,
          firefox: true,
          opengraph: true,
          twitter: true,
          yandex: false,
          windows: false
        }
      }),
    ],

    output: {
      path: __dirname + '/dist',
      filename: 'app-[hash].js'
    },

    module: {
      rules: [
        {
          test:  /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: 'elm-webpack-loader'
        },
        {
          test: /\.(css|scss)$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: ExtractTextPlugin.extract({
            fallbackLoader: 'style-loader',
            use: styleLoaders
          })
        }
      ]
    }
  });
}
