import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '../store/index'

Vue.use(VueRouter)

const routes = [
    // {
    //     path: '/',
    //     component: () => import(/* webpackChunkName: "about" */ '../views/settings/index.vue')
    // },
    {
        path: '/settings',
        name: 'settings',
        component: () => import(/* webpackChunkName: "about" */ '../views/settings/index.vue')
    }, {
        path: '/analysis',
        name: 'analysis',
        component: () => import(/* webpackChunkName: "about" */ '../views/analysis/index.vue')
    }, {
        path: '/customerService',
        name: 'customerService',
        component: () => import(/* webpackChunkName: "about" */ '../views/customerService/index.vue')
    }, {
        path: '/userInfo',
        name: 'userInfo',
        component: () => import(/* webpackChunkName: "about" */ '../views/userInfo/index.vue')
    }, {
        path: '/userInfo/details',
        name: 'userInfo-details',
        component: () => import(/* webpackChunkName: "about" */ '../views/userInfo/details/index.vue')
    }, {
        path: '/userInfo/editPhoneNo',
        name: 'userInfo-editPhoneNo',
        component: () => import(/* webpackChunkName: "about" */ '../views/userInfo/editPhoneNo/index.vue')
    }, {
        path: '/publicPage',
        name: 'publicPage',
        component: () => import(/* webpackChunkName: "about" */ '../views/publicPage/index.vue')
    }, {
        path: '/monthlyBill',
        name: 'monthlyBill',
        component: () => import(/* webpackChunkName: "about" */ '../views/monthlyBill/index.vue')
    }, {
        path: '/monthlyBill/details',
        name: 'monthlyBillDetails',
        component: () => import(/* webpackChunkName: "about" */ '../views/monthlyBill/details/index.vue')
    }, {
        path: '/ledger',
        name: 'ledger',
        component: () => import(/* webpackChunkName: "about" */ '../views/ledger/index.vue')
    }, {
        path: '/analysis/cateogryList',
        name: 'analysis-cateogryList',
        component: () => import(/* webpackChunkName: "about" */ '../views/analysis/cateogryList/index.vue')
    }, {
        path: '/asset',
        name: 'asset',
        component: () => import(/* webpackChunkName: "about" */ '../views/asset/index.vue')
    },
    {
        path: '/asset/diagnosis',
        name: 'asset-diagnosis',
        component: () => import(/* webpackChunkName: "about" */ '../views/asset/diagnosis/index.vue')
    },
    {
        path: '/earnings',
        name: 'earnings',
        component: () => import(/* webpackChunkName: "about" */ '../views/earnings/index.vue')
    }
]

const router = new VueRouter({
    // mode: 'history',
    mode: 'hash',
    base: process.env.BASE_URL,
    routes
})
export default router
