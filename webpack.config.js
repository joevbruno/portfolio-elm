var webpack = require('webpack'),
    path     = require('path'),
    HtmlWebpackPlugin = require('html-webpack-plugin'),
    validate = require('webpack-validator');
var debug = process.env.NODE_ENV === 'development';
var devServer = 'webpack-dev-server/client?http://localhost:8080';
var main = path.resolve(__dirname, 'src/index.js');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var autoprefixer      = require('autoprefixer');
var CopyWebpackPlugin = require('copy-webpack-plugin');

console.log(debug)
var productionPlugins = debug ? [] : [
     new webpack.optimize.UglifyJsPlugin({
        minimize:   true,
        compressor: { warnings: false },
        mangle:  true
    }),
    new webpack.optimize.OccurenceOrderPlugin(),
    new CopyWebpackPlugin([
        {
            from: 'src/favicon.ico'
        }
    ])
];

module.exports = validate({
    devtool: "eval",
    entry: debug ? [ devServer, main ] : [ main ],
    resolve: {
        modulesDirectories: ['node_modules'],
        extensions: ['','.js','.elm'],
    },
    output: {
        path: path.resolve(__dirname, 'docs'),
        filename: 'js/[name].[hash].js',
        chunkFilename: "[name].js?[hash]-[chunkhash]",
        publicPath: "./"
    },
    plugins: [
        new HtmlWebpackPlugin({
            template: path.resolve('./src/index.html'),
            filename: 'index.html'
        }),
        new ExtractTextPlugin("css/main.css", {
            disable: debug,
            allChunks: true
        })
    ].concat(productionPlugins),
    postcss: [ autoprefixer( { browsers: ['last 2 versions'] } ) ],
    module: {
        loaders:
            [
                {
                    test: /\.elm$/,
                    loader: debug ? 'elm-hot!elm-webpack?verbose=true&warn=true': 'elm-webpack',
                    exclude: [
                        /node_modules/,
                        /elm-stuff/
                    ]
                },
                {
                    test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
                    loader: "file?name=[name].[ext]"
                },

                {
                    test: /\.scss$/,
                    loader: ExtractTextPlugin.extract("style-loader", "css-loader!postcss-loader!sass-loader")
                }
            ]
    }
});
