<template>
  <div id="app">
    <router-view/>
  </div>
</template>
<script>

import {mapMutations, mapState, mapActions} from 'vuex'
import {login} from '@/api'

export default {
  data() {
    return {}
  },
  computed: {
    ...mapState(['token', 'statusBarHeight', 'appBarHeight']),
  },
  mounted() {
    // 监听Flutter传来的数据
    window.addEventListener('flutter_setToken', this.handleFlutterData);
    // this.handleFlutterData()
  },
  beforeUnmount() {
    window.removeEventListener('flutter_setToken', this.handleFlutterData);
  },
  methods: {
    ...mapMutations(['init_token', 'app_bar_height', 'status_bar_height']),
    ...mapActions(['get_user_info']),
    handleFlutterData(event) {
      if (event?.detail) {
        this.init_token({
          token: event.detail.token
        })
        this.app_bar_height({
          height: event.detail.appBarHeight
        })
        this.status_bar_height({
          height: event.detail.statusBarHeight
        })
        this.get_user_info()
      } else {
        const username = process.env.VUE_APP_DEMO_USERNAME
        const password = process.env.VUE_APP_DEMO_PASSWORD
        if (!username || !password) return
        login({
          username,
          password
        }).then((res) => {
          if (res.data.code === 200) {
            this.init_token({
              token: res.data.data.access_token
            })
            this.get_user_info()
          }
        })
      }
    },
  }
}
</script>
<style lang="scss">
#app {
  width: 100%;
  height: 100%;
}

</style>
