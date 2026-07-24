<template>
  <div class="settings">
    <nav-bar title="设置" service-icon></nav-bar>
    <div class="main">
      <div class="user-info">
        <img class="user-header" src="@/assets/image/home/header.png" alt="">
        <div class="user-content">
          <div class="user-name">{{ maskName }}</div>
          <div class="user-number">{{ phone }}</div>
        </div>
        <div class="user-edit" @click="goUserInfo">
          <span>个人信息修改</span>
          <img class="user-edit-icon" src="@/assets/image/home/right.png" alt="">
        </div>
      </div>
      <div class="settings-content">
        <img class="settings-content-bg" src="@/assets/image/home/setting.png" alt="">
        <div class="security-center">
          <div class="item" @click="goPublicPage({
          title:'登录管理',
          imageUrl:require('@/assets/image/home/loginManagement.png'),
          serviceIcon:false
          })"></div>
          <div class="item" @click="goPublicPage({
          title:'交易限额设置',
          imageUrl:require('@/assets/image/home/jyxesz.png'),
          serviceIcon:true
          })"></div>
          <div class="item" @click="goPublicPage({
          title:'安全工具',
          imageUrl:require('@/assets/image/home/aqgj.png'),
          serviceIcon:false
          })"></div>
          <div class="item" @click="goPublicPage({
          title:'操作记录',
          imageUrl:require('@/assets/image/home/czjl.png'),
          serviceIcon:false
          })"></div>

        </div>
      </div>
    </div>
  </div>
</template>
<script>
import {mapState} from "vuex";

export default {
  name: "settings",
  data() {
    return {}
  },
  computed: {
    ...mapState(['userInfo']),
    // app那边拷贝过来的逻辑
    maskName() {
      const name = this.userInfo.realName || '';
      // 处理空值/空字符串
      if (name == null || name.trim().isEmpty) {
        return "";
      }
      const realName = name.trim();
      const length = realName.length;

      // 单字名：直接返回（无脱敏必要）
      if (length == 1) {
        return realName;
      }
      // 两字名：第二个字替换为*
      else if (length == 2) {
        return `${realName.substring(0, 1)}*`;
      }
      // 超两字名：首尾保留，中间全替换为*
      else {
        const firstChar = realName.substring(0, 1);
        const lastChar = realName.substring(length - 1);
        // 计算中间需要替换的*数量 
        let middleStars = "";
        for(let i = 0; i < length - 2; i++) {
          middleStars += "*";
        }
        return `${firstChar} ${middleStars} ${lastChar}`;
      }
    },
    phone() {
      const tempPhone = this.userInfo.phone || "";
      const length = tempPhone.length;
      const prefix = tempPhone.substring(0, 3);
      const suffix = tempPhone.substring(length - 4);
      return `${prefix} **** ${suffix}`;
    }
  },
  mounted() {
  },
  methods: {
    goUserInfo() {
      this.$router.push({
        path: `/userInfo`,
      })
    },
    goPublicPage(query) {
      this.$router.push({
        path: '/publicPage',
        query: query
      })
    },
  }
}
</script>

<style scoped lang="scss">
.settings {
  width: 100%;
  background-color: #F4F4F4;
  min-height: 100vh;
}

.main {
  width: 100%;

  .settings-content {
    width: 100%;
    position: relative;
    padding-top: 0.8rem;

    .settings-content-bg {
      width: 100%;
      height: 24.16rem;
      position: absolute;
      top: 0;
      left: 0;
    }
  }

  .security-center {
    position: relative;
    width: 100%;
    height: 2rem;
    display: flex;
    align-items: center;
    justify-content: space-around;

    .item {
      width: 20%;
      height: 100%;
    }
  }

  .user-info {
    width: 100%;
    background-color: #ffffff;
    padding: 0.34rem 0.37rem 0.34rem 0.48rem;
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: space-between;

    .user-header {
      width: 0.82rem;
      height: 0.82rem;
    }

    .user-content {
      height: 0.82rem;
      display: flex;
      margin-left: 0.3rem;
      flex: 1;
      line-height: 1;
      justify-content: space-between;
      flex-direction: column;

      .user-name {
        color: #222222;
        font-size: 0.3rem;

        font-weight: 700;
      }

      .user-number {
        color: #666666;
        font-size: 0.28rem;
      }

    }

    .user-edit {
      display: flex;
      align-items: center;
      color: #666666;
      font-size: 0.26rem;

      .user-edit-icon {
        width: 0.14rem;
        height: 0.24rem;
        margin-left: 0.2rem;
      }
    }
  }
}
</style>
