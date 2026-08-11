/* 创建一个utils文件夹在文件下单独创建一个文件request.js可以在这里定义一些默认配置 包括一些需要统一做拦截的处理 */
import axios from 'axios'
import store from '../store/index'
// 创建一个实例
const request = axios.create({
    baseURL:  'http://api.jianshewap.cc' ,
    // baseURL:  '/api' ,
    // baseURL: process.env.NODE_ENV === 'development'
    //     ? '/api'
    //     : 'http://47.102.135.129:8001',
    timeout: 30000
})

// 添加一个请求的拦截器
request.interceptors.request.use(function (config) {
    let token = store.state.token
    // let token = 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyX2lkIjo4OTE5LCJ1c2VyX2tleSI6IjNhZDg1MTIyLTVlOTEtNGEyOC04ZTEwLTAzNjNlOTVlNjkyZiIsInVzZXJuYW1lIjoiMTM4NjY2NjU1NTUifQ.JlCkaVCzCHf8Lv73vO2wlf7zq1wbqienU4fgzTGUREXUrOCzCQmXd_fZT2JjCWeQGVr7bBOUARXjNYwEWy47mg'
    if (token) {
        config.headers.Authorization = token
    }
    config.headers.client_type = 'APP'
    config.headers.BANKTYPE = '5'
    return config
}, function (error) {
    // 请求失败了
    return Promise.reject(error)
})
// 添加响应拦截
request.interceptors.response.use(function (response) {
    return response
}, function (error) {
    // http状态码不是2xx
    return Promise.reject(error)
})
// 导出
export default request
