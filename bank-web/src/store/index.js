import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'
import {getWxUserInfo} from '../api/index'

Vue.use(Vuex)

export default new Vuex.Store({
    state: {
        token: '', // 登录token
        userInfo: {}, // 用户信息
        appBarHeight: 0,// app 标题栏高度 0.88是给的默认调试用的
        statusBarHeight: 0,//app 状态栏高度
    },
    getters: {},
    mutations: {
        init_token(state, payload) { // 改变token
            state.token = payload.token
        },
        init_user_info(state, payload) {
            state.userInfo = payload.userInfo
        },
        status_bar_height(state, payload) {
            state.statusBarHeight = payload.height
        },
        app_bar_height(state, payload) {
            state.appBarHeight = payload.height
        },
    },
    actions: {
        get_user_info({
                          commit,
                          state
                      }) {
            if (state.token && state.token !== 'undefined') {
                // 获取用户信息
                return getWxUserInfo().then(res => {
                    if (res.data.code === 200) {
                        commit('init_user_info', {
                            userInfo: res.data.data,
                        })
                    }
                })
            } else {
                commit('init_user_info', {
                    userInfo: {},
                })
            }
        }
    },
    modules: {},
    plugins: [createPersistedState()]
})
