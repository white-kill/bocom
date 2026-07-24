<template>
  <div class="app">
    <nav-bar title="修改手机号"></nav-bar>
    <div class="main">
      <div class="title">可修改手机号</div>
      <div class="info">
        <div class="item">
          <div class="label">核心用户信息</div>
          <div class="content">{{phone}}</div>
        </div>
        <div class="item">
          <div class="label">登录手机银行</div>
          <div class="content">{{phone}}</div>
        </div>
        <div class="item">
          <div class="label">接受手机<br>交易码</div>
          <div class="content">{{phone}}</div>
        </div>
        <div class="item">
          <div class="label">电子银行客户<br>信息</div>
          <div class="content">{{phone}}</div>
        </div>
      </div>
      <div class="btn">下一步</div>
      <div class="tips">
        温馨提示：<br>
        1.修改手机号后，原手机号将被整合并统一修改为您新的手机号，原手机号不再用于所列服务中且从所列服务信息中删除。<br>
        2.本功能暂仅支持在我行预留证件为二代居民身份证的客户使用，其他证件客户请您持本人有效身份证件、任一电子银行关联账户至我行网点柜台进行手机号修改。
        3.建议您于每日07:00-22:00使用本功能。<br>
        4.修改手机号服务需要进行人脸识别并验证您任一电子银行关联账户的密码，同时验证认证工具（包括中银e令/ SI
        M盾/中银e盾/ 手机盾）。如您尚未签约前述认证工具，则暂无法办理本服务。您可通过手机银行自助
        <span>开通手机盾</span> 后再办理本服务，也可持本人有效身份证件、任一电子银行关联账户至我行网点柜台进行手机号修改或柜台签约相关认证工具后再通过手机银行办理本服务。
      </div>
    </div>
  </div>

</template>
<script>
import {mapState} from "vuex";
export default {
  computed: {
    ...mapState(['userInfo']),
    phone() {
      const tempPhone = this.userInfo.phone || "";
      const length = tempPhone.length;
      const prefix = tempPhone.substring(0, 3);
      const suffix = tempPhone.substring(length - 4);
      return `${prefix} **** ${suffix}`;
    }
  },
}
</script>
<style scoped lang="scss">
.app {
  width: 100%;
  min-height: 100vh;
  background-color: #F4F4F4;
}

.main {
  width: 100%;

  .tips {
    padding: 0 0.3rem;
    font-size: 0.24rem;
    color: #666666;
    line-height: 0.4rem;

    span {
      color: #0066EF;
    }
  }

  .btn {
    width: 5.9rem;
    height: 0.6rem;
    line-height: 0.6rem;
    font-weight: 700;
    margin: 0.6rem auto;
    background-color: #0066EF;
    text-align: center;
    border-radius: 0.04rem;
    font-size: 0.26rem;
    color: #ffffff;
  }

  .info {
    width: 7.3rem;
    background-color: #ffffff;
    border-radius: 0.04rem;
    margin: auto;
    padding: 0 0.3rem;
    box-sizing: border-box;

    .item {
      width: 100%;
      display: flex;
      font-size: 0.26rem;
      align-items: center;
      justify-content: space-between;
      height: 0.8rem;
      line-height: 1.2;
      border-bottom: 0.01rem solid #F4F4F4;

      .label {
        color: #222222;
        font-weight: 700;
      }

      .content {
        color: #666666;
      }
    }
  }

  .title {
    width: 100%;
    padding: 0 0.3rem;
    height: 0.68rem;
    font-size: 0.28rem;
    line-height: 0.68rem;

  }

}
</style>
