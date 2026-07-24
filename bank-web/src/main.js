import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
// 引入rem适配文件
import './rem'
// 引入reset文件
import './assets/css/reset.css'
// config全局
import Vant from 'vant';
import 'vant/lib/index.css';
import components from './utils/components'
//基本属性js配置
import config from "./config"
Vue.prototype.$config = config
Vue.use(Vant);
Vue.use(components)
Vue.config.productionTip = false
window.vueRouter = router
new Vue({
  router,
  store,
  render: function (h) { return h(App) }
}).$mount('#app')
