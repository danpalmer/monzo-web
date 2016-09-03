var merge = require('webpack-merge');
var webpack = require('webpack');
var writefile = require('writefile');
var autoprefixer = require('autoprefixer');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'prod' : 'dev';

var commonConfig = {

    entry: './src/app/app.js',

    resolve: {
        modulesDirectories: ['node_modules'],
        extensions:         ['', '.js', '.elm']
    },

    module: {
        loaders: [
            {
                test:    /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader:  'elm-hot!elm-webpack'
            },
            {
                test: /\.(css|scss)$/,
                loader: ExtractTextPlugin.extract('style-loader', [
                    'css-loader',
                    'postcss-loader',
                    'sass-loader'
                ])
            },
            { test: /\.woff2?$/, loader: "url-loader?limit=10000&mimetype=application/font-woff" },
            { test: /\.ttf$/,  loader: "url-loader?limit=10000&mimetype=application/octet-stream" },
            { test: /\.eot$/,  loader: "file-loader" },
            { test: /\.svg$/,  loader: "url-loader?limit=10000&mimetype=image/svg+xml" },
            { test: /\.(png|jpg|jpeg|gif|woff)$/, loader: 'url-loader?limit=8192' }
        ],

        noParse: [/\.elm$/]
    },

    plugins: [
        new ExtractTextPlugin('styles.css', {allChunks: true}),
        new HtmlWebpackPlugin({
            filename: 'index.html',
            template: './src/index.html',
            hash: true
        })
    ],

    postcss: [
        autoprefixer({browsers: ['last 2 versions']})
    ],
};

if (TARGET_ENV === 'dev') {
    module.exports = merge(commonConfig, {
        output: {
            path: './build',
            filename: 'app.js'
        },

        devServer: {
            inline: true,
            historyApiFallback: true,
            colors: true,
            noInfo: true,
            watchOptions: {
                aggregateTimeout: 300,
                poll: 1000
            },
            stats: {
                colors: true
            }
        },
    });
}

if (TARGET_ENV === 'prod') {
    module.exports = merge(commonConfig, {
        plugins: [
            new webpack.optimize.UglifyJsPlugin({
                minimize: true,
                compressor: {warnings: false},
                mangle: true
            })
        ],

        output: {
            path: './dist',
            filename: 'app.js'
        }
    });
}
