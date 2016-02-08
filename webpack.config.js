var merge = require('webpack-merge');
var webpack = require('webpack');
var writefile = require('writefile');
var autoprefixer = require('autoprefixer');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'prod' : 'dev';

var commonConfig = {

    entry: './src/app.js',

    output: {
        path: './build',
        filename: 'app.js'
    },

    resolve: {
        modulesDirectories: ['node_modules'],
        extensions:         ['', '.js', '.elm']
    },

    module: {
        loaders: [
            {
                test:    /\.elm$/,
                exclude: [/node_modules/],
                loader:  'elm-webpack'
            },
            {
                test: /\.(css|scss)$/,
                loader: ExtractTextPlugin.extract('style-loader', [
                    'css-loader',
                    'postcss-loader',
                    'sass-loader'
                ])
            }
        ],

        noParse: /\.elm$/
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
    ]
};

if (TARGET_ENV === 'dev') {
    module.exports = merge(commonConfig, {
        devServer: {
            inline: true,
            stats: 'errors-only'
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
        ]
    });
}
