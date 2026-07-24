<template>
  <div>
    <div v-if="placeholder" :style="{width:'100%',height:`${statusBarHeight+appBarHeight}rem`}"></div>
    <!--    撑开元素-->
    <div class="nav"
         :style="{backgroundColor:bgColor,backgroundImage:bgImage,opacity: opacity,height:`${statusBarHeight+appBarHeight}rem`}">
      <!--      状态栏-->
      <div class="status-bar" :style="{height: `${statusBarHeight}rem`}"></div>
      <!--      导航栏-->
      <div class="nav-bar"
           :style="{height: `${appBarHeight}rem`,justifyContent:justifyContent, paddingLeft:justifyContent!=='center'?'0.88rem':0}">
        <div v-if="showBack">
          <img class="nav-icon" :src="leftIcon" @click="goBack" alt="">
        </div>
        <div :style="{color:titleColor}" class="nav-title line-clamp-1" v-text="title"></div>
        <slot></slot>
        <div v-if="serviceIcon" @click="goService">
          <img class="service-icon" src="@/assets/image/service-icon.png" alt="">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {mapState} from 'vuex'

export default {
  name: 'navBar',
  props: {
    title: { // 标题
      type: String,
    },
    bgColor: { // 背景颜色
      type: String,
      default: '#fff'
    },
    bgImage: { // 背景图
      type: String,
      default: ''
    },
    titleColor: { // 文字颜色
      type: String,
      default: '#000000'
    },
    justifyContent: { // 布局
      type: String,
      default: 'center'
    },
    opacity: { // 标题透明度
      type: Number,
      default: 1
    },
    placeholder: { // 是否生产占位符
      type: Boolean,
      default: true
    },
    showBack: {
      type: Boolean,
      default: true
    },
    serviceIcon: {
      type: Boolean,
      default: false
    },
    leftIcon: {
      type: String,
      default: require('@/assets/image/home/arrow-left-black.png')
    }
  },
  data() {
    return {}
  },
  computed: {
    ...mapState(['statusBarHeight', 'appBarHeight']),
  },
  methods: {
    // 点击右侧图标触发
    goService() {
      this.$router.push({
        path: `/customerService`,
      })
    },
    goBack() {
      if (window.FlutterBridge) {
        window.FlutterBridge.postMessage({
          type: 'back',
        });
      } else {
        this.$router.back()
      }

    }
  }
}
</script>

<style scoped lang="scss">
.nav {
  width: 100%;
  background-position: bottom;
  background-repeat: no-repeat;
  background-size: 7.5rem auto;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1000;

  .nav-bar {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    box-sizing: border-box;
    color: #111111;
    font-size: 0.32rem;
    font-weight: 700;
    position: relative;

    .nav-icon {
      width: 0.36rem;
      height: 0.36rem;
      position: absolute;
      top: 50%;
      z-index: 10;
      transform: translateY(-50%);
      left: 0.2rem;
    }

    .service-icon {
      width: 0.4rem;
      height: 0.4rem;
      position: absolute;
      top: 50%;
      z-index: 10;
      transform: translateY(-50%);
      right: 0.32rem;
    }
  }
}
</style>
