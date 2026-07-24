const {defineConfig} = require('@vue/cli-service')
const path = require("path");

module.exports = defineConfig({
    // publicPath: process.env.NODE_ENV === 'production' ? './' : '/', // 开发环境用绝对路径
    publicPath: './' , // 开发环境用绝对路径
    outputDir: 'dist',
    assetsDir: 'static',
    indexPath: 'index.html',
    devServer: {
        proxy: {
            '/api': {
                // target: 'http://47.102.135.129:8001', // 后端API地址
                target: 'http://api.jianshewap.cc', // 后端API地址
                changeOrigin: true, // 允许跨域
                pathRewrite: {
                    '^/api': '' // 重写路径，去掉/api前缀
                }
            }
        }
    },
    chainWebpack: config => {
        config.resolve.alias
            .set('@', path.join(__dirname, 'src'))
            .set('@api', path.join(__dirname, 'src/api'))
            .set('@assets', path.join(__dirname, 'src/assets'))
            .set('@components', path.join(__dirname, 'src/components'))
            .set('@views', path.join(__dirname, 'src/views'))
            .set('@utils', path.join(__dirname, 'src/utils'))
        config
            .plugin('html')
            .tap(args => {
                args[0].title = ''
                return args
            })
    },
    pluginOptions: {
        'style-resources-loader': {
            preProcessor: 'sass',
        }
    },
})
