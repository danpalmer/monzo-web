var merge = require('webpack-merge');
var webpack = require('webpack');
var writefile = require('writefile');
var autoprefixer = require('autoprefixer');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');
var FaviconsWebpackPlugin = require('favicons-webpack-plugin');

var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'prod' : 'dev';

var commonConfig = {

    entry: './src/app/app.js',

    resolve: {
        modulesDirectories: ['node_modules'],
        extensions:         ['', '.js', '.elm']
    },

    module: {
        loaders: [
            { test: /\.woff2?$/, loader: "url-loader?limit=10000&mimetype=application/font-woff" },
            { test: /\.ttf$/,  loader: "url-loader?limit=10000&mimetype=application/octet-stream" },
            { test: /\.eot$/,  loader: "file-loader" },
            { test: /\.svg$/,  loader: "url-loader?limit=10000&mimetype=image/svg+xml" },
            { test: /\.(png|jpg|jpeg|gif|woff)$/, loader: 'url-loader?limit=8192' }
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
            progress: true,
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
                    test:    /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader:  'elm-hot!elm-webpack?verbose=true&warn=true'
                },
                {
                    test: /\.(css|scss)$/,
                    loaders: [
                        'style-loader',
                        'css-loader',
                        'postcss-loader',
                        'sass-loader'
                    ]
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
            new webpack.optimize.OccurenceOrderPlugin(),
            new ExtractTextPlugin('styles-[contenthash].css'),
            new FaviconsWebpackPlugin({
                logo: './src/images/monzo.svg',
                prefix: 'icons/',
                background: '#16243b',
                title: 'Monzo Web',
                icons: {
                    android: false,
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
            new ProgressBarPlugin({
                renderThrottle: 500
            })
        ],

        output: {
            path: './dist',
            filename: 'app-[hash].js'
        },

        module: {
            loaders: [
                {
                    test:    /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader:  'elm-webpack'
                },
                {
                    test: /\.(css|scss)$/,
                    loader: ExtractTextPlugin.extract( 'style-loader', [
                        'css-loader',
                        'postcss-loader',
                        'sass-loader'
                    ])
                }
            ]
        }
    });
}
