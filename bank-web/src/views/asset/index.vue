<template>
  <div class="app">
    <nav-bar
      title="资产管理"
      :showBack="false"
      :title-color="`rgba(${255 * opacity},${255 * opacity},${
        255 * opacity
      },1)`"
      :bg-color="`rgba(255,255,255,${1 - opacity})`"
      :placeholder="false"
    >
      <div class="nav-title">
        <img
          @click="goBack"
          v-if="opacity < 0.5"
          class="nav-back"
          src="@/assets/image/home/arrow-left-black.png"
          alt=""
        />
        <img
          @click="goBack"
          v-else
          class="nav-back nav-back-1"
          src="@/assets/image/home/arrow-left.png"
          alt=""
        />
        <div class="nav-right">
          <img
            v-if="opacity < 0.5"
            class="nav-image"
            src="@/assets/image/home/service-icon-black.png"
            alt=""
          />
          <img
            v-else
            class="nav-image"
            src="@/assets/image/home/service-icon-white.png"
            alt=""
          />
          <img
            v-if="opacity < 0.5"
            class="nav-image"
            src="@/assets/image/home/rl-icon-black.png"
            alt=""
          />
          <img
            v-else
            class="nav-image"
            src="@/assets/image/home/rl-icon-white.png"
            alt=""
          />
        </div>
      </div>
    </nav-bar>
    <div class="main">
      <div class="header">
        <div class="header-notice">
          <van-notice-bar color="#fff" background="rgba(0, 0, 0, 0)" scrollable>所涉及相关资产负债及明细信息可能会存在更新延迟等情况</van-notice-bar>
        </div>
        <div class="header-corner" @click="goZczd">资产诊断</div>
        <div class="header-ears">
          <img
            v-if="earsClose"
            @click="earsClose = false"
            class="header-ears-icon"
            src="@/assets/image/home/eye-open-yellow.34542cd5.png"
            alt=""
          />
          <img
            v-else
            @click="earsClose = true"
            class="header-ears-icon"
            src="@/assets/image/home/eye-close-yellow.471f450c.png"
            alt=""
          />
        </div>
        <div class="header-time">
          <span>{{ time }}</span>
          <img
            @click="formatDate()"
            class="header-time-icon"
            src="@/assets/image/home/refresh.fcfd5199.png"
            alt=""
          />
        </div>
        <div class="asset">
          <div
            :class="['asset-item', type === '1' ? 'asset-item-1' : '']"
            @click="type = '1'"
          >
            <div class="title">总资产</div>
            <div>
              {{ earsClose ? formatAmount(userInfo.accountBalance.toFixed(2)) : "*****" }}
            </div>
          </div>
          <div
            :class="['asset-item', type === '2' ? 'asset-item-2' : '']"
            @click="type = '2'"
          >
            <div class="title">总负债</div>
            <div>{{ earsClose ? "0.00" : "*****" }}</div>
          </div>
        </div>
        <div class="line"></div>
      </div>
      <div class="asset-details">
        <div class="asset-details-content" v-if="type === '1'">
          <div v-if="earsClose" class="asset-details-image">
            <div v-if="isOpen">
              <img
                class="asset-image-1"
                src="@/assets/image/home/myAssets-open3.39d3cb04.png"
                alt=""
              />
            </div>
            <div v-else>
              <img
                class="asset-image-3"
                src="@/assets/image/home/myAssets-open2.ef70d4cb.png"
                alt=""
              />
            </div>
          </div>
          <div v-else class="asset-details-image">
            <div v-if="isOpen">
              <img
                class="asset-image-4"
                src="@/assets/image/home/myAssets-open.f6f25fd9.png"
                alt=""
              />
            </div>
            <div v-else>
              <img
                class="asset-image-5"
                src="@/assets/image/home/myAssets-close.617fe9d6.png"
                alt=""
              />
            </div>
          </div>
          <div class="open" @click="isOpen = !isOpen"></div>
          <div class="asset-details-money" v-if="earsClose">
            {{ formatAmount(userInfo.accountBalance.toFixed(2)) }}
          </div>
          <div class="asset-details-money2" v-if="earsClose">0.00</div>
        </div>
        <div class="asset-details-content" v-if="type === '2'">
          <img
            class="asset-image-2"
            src="@/assets/image/home/myAssets-type.d7a0aeb5.png"
            alt=""
          />
          <div class="asset-money-2">{{ earsClose ? "0.00" : "*****" }}</div>
        </div>
      </div>
      <div
        class="footer"
        :style="{ marginTop: type === '1' ? '-0.10rem' : '' }"
      >
        <img
          class="footer-image"
          src="@/assets/image/home/myAssets-pages.png"
          alt=""
        />
      </div>
    </div>
  </div>
</template>
<script>
import { remToPx } from "@/utils";
import { mapState } from "vuex";
import {formatAmount} from '@/utils'

export default {
  name: "index",
  data() {
    return {
      formatAmount: formatAmount,
      opacity: 1, // 标题透明度
      earsClose: false,
      time: "",
      type: "1", // 1总资产 2总负债
      isOpen: false,
    };
  },
  mounted() {
    // 监听页面滚动事件
    window.addEventListener("scroll", this.scrolling);
    this.formatDate();
  },
  computed: {
    ...mapState(["userInfo"]),
  },
  methods: {
    formatDate(date = new Date()) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const day = String(date.getDate()).padStart(2, "0");
      const hours = String(date.getHours()).padStart(2, "0");
      const minutes = String(date.getMinutes()).padStart(2, "0");
      const seconds = String(date.getSeconds()).padStart(2, "0");
      this.time = `${year}/${month}/${day}   ${hours}:${minutes}:${seconds}`;
    },
    goBack() {
      if (window.FlutterBridge) {
        window.FlutterBridge.postMessage({
          type: "back",
        });
      } else {
        this.$router.back();
      }
    },
    goZczd() {
      // 资产诊断页面
      // window.FlutterBridge.postMessage({
      //   type: "zczd",
      // });
       this.$router.push({
        path: `/asset/diagnosis`,
      })
    },
    // 页面滚动事件
    scrolling() {
      let scrollTop =
        window.pageYOffset ||
        document.documentElement.scrollTop ||
        document.body.scrollTop; // 兼容处理
      if (scrollTop >= remToPx(6)) {
        this.opacity = 0;
      } else if (scrollTop === 0) {
        this.opacity = 1;
      }
      this.opacity = 1 - scrollTop / remToPx(6).toFixed(2);
    },
  },
};
</script>
<style scoped lang="scss">
.app {
  width: 100%;
}

::v-deep .nav .nav-icon {
  width: 0.17rem;
}

.nav-title {
  width: 100%;
  position: absolute;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-right: 0.3rem;
  box-sizing: border-box;
  padding-left: 0.2rem;

  .nav-back {
    width: 0.36rem;
    height: 0.36rem;
    display: block;
  }

  .nav-right {
    display: flex;
    align-items: center;

    .nav-image {
      width: 0.48rem;
      height: 0.48rem;
      margin-left: 0.4rem;
    }
  }

  .nav-back-1 {
    width: 0.17rem;
    margin-left: 0.1rem;
  }
}

.main {
  width: 100%;

  .footer {
    width: 100%;

    .footer-image {
      width: 100%;
      height: 13.56rem;
      display: block;
    }
  }

  .asset-details {
    width: 100%;
    position: relative;

    .asset-details-content {
      width: 100%;
      position: relative;

      .asset-details-money {
        position: absolute;
        color: #222222;
        font-size: 0.36rem;
        font-weight: bold;
        left: 0.58rem;
        top: 1.55rem;
      }

      .asset-details-money2 {
        position: absolute;
        color: #222222;
        font-size: 0.36rem;
        font-weight: bold;
        left: calc(50% + 0.3rem);
        top: 1.55rem;
      }

      .open {
        position: absolute;
        left: 50%;
        bottom: 0;
        height: 1rem;
        width: 2rem;
        transform: translateX(-50%);
        z-index: 2;
      }

      .asset-details-image {
        margin-top: -0.9rem;
      }

      .asset-image-2 {
        width: 7.5rem;
        height: 2.03rerm;
        display: block;
        margin-top: -0.02rem;
      }

      .asset-image-1 {
        width: 7.5rem;
        height: 12.639rem;
        display: block;
      }

      .asset-image-3 {
        width: 7.5rem;
        height: 9.236rem;
        display: block;
      }

      .asset-image-4 {
        width: 7.5rem;
        height: 11.3125rem;
        display: block;
      }

      .asset-image-5 {
        width: 7.5rem;
        height: 8.257rem;
        display: block;
      }

      .asset-money-2 {
        position: absolute;
        color: #222222;
        font-size: 0.4rem;
        font-weight: 700;
        bottom: 0.4rem;
        left: 0.7rem;
      }
    }
  }

  .header {
    width: 7.5rem;
    height: 5.78rem;
    background-image: url("@/assets/image/home/myAssets04.png");
    background-size: cover;
    background-position: bottom;
    background-repeat: no-repeat;
    position: relative;

    .asset {
      width: 100%;
      position: absolute;
      font-size: 0.4rem;
      font-weight: 700;
      display: flex;
      bottom: 0.9rem;
      color: #c4c7cb;

      .asset-item {
        width: 50%;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;

        .title {
          font-size: 0.3rem;
        }
      }

      .asset-item-1 {
        color: #f9d8ab;
      }

      .asset-item-2 {
        color: #ffffff;
      }
    }

    .line {
      background: #9d968e;
      width: 0.02rem;
      height: 1rem;
      position: absolute;
      left: 50%;
      transform: translateX(-50%);
      bottom: 1rem;
    }

    .header-notice {
      position: absolute;
      bottom: 3.7rem;
      left: 0;
      width: 100%;
    }

    .header-corner {
      position: absolute;
      bottom: 2.6rem;
      right: 0.1rem;
      font-size: 0.22rem;
      color: #222;
      width: 1.5rem;
      height: 0.7rem;
      display: flex;
      align-items: center;
      justify-content: flex-end;
    }

    .header-time {
      display: flex;
      align-items: center;
      font-size: 0.26rem;
      color: #ffffff;
      line-height: 1;
      position: absolute;
      left: 0.36rem;
      bottom: 2.46rem;

      .header-time-icon {
        width: 0.32rem;
        height: 0.32rem;
      }
    }

    .header-ears {
      width: 0.48rem;
      height: 0.36rem;
      position: absolute;
      bottom: 2.9rem;
      left: 3.82rem;

      .header-ears-icon {
        width: 0.48rem;
        height: 0.36rem;
        display: block;
      }
    }
  }
}
</style>
