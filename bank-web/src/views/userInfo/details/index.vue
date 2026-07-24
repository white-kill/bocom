<template>
  <div class="details">
    <nav-bar title="个人信息"></nav-bar>
    <div class="main">
      <div class="warning">
        <img class="warning-image" src="@/assets/image/home/remind.png" alt="">
        <div>为确保操作成功，建议您在每日北京时间07:00-22:00期间通过电子银行进行个人信息修改。</div>
      </div>
      <div class="title">基本信息</div>
      <div class="item">
        <div class="label">电子银行<br>客户序号</div>
        <div class="content content-1">{{ userInfo.chapterCode }}</div>
      </div>
      <div class="item">
        <div class="label">姓名</div>
        <div class="content">{{ maskedString(userInfo.realName) }}</div>
      </div>
      <div class="item">
        <div class="label">英文/拼音<br>姓氏</div>
        <div class="content">{{ maskedString(pinyin(userInfo.realName[0],{ toneType: 'none' }).toUpperCase()) }}</div>
      </div>
      <div class="item">
        <div class="label">英文/拼音名</div>
        <div class="content">{{ maskedString(pinyin(userInfo.realName,{ toneType: 'none' }).toUpperCase()) }}</div>
      </div>
      <div class="item">
        <div class="label">证件类型</div>
        <div class="content">居民身份证</div>
      </div>
      <div class="item">
        <div class="label">证件号码</div>
        <div class="content">{{ idCard }}</div>
      </div>
      <div class="item">
        <div class="label">国家/地区</div>
        <div class="content">中国</div>
      </div>
      <div class="item">
        <div class="label">民族</div>
        <div class="content">汉族</div>
      </div>
      <div class="item">
        <div class="label">性别</div>
        <div class="content">{{ userInfo.sex == '1' ? '男' : '女' }}</div>
      </div>
      <div class="item">
        <div class="label">出生日期</div>
        <div class="content">{{extractBirthday}}</div>
      </div>
      <div class="item">
        <div class="label">出生地</div>
        <div class="content">{{ userInfo.city }}</div>
      </div>
      <div class="title">证件地址信息</div>
      <div class="item">
        <div class="label">国家/地区</div>
        <div class="content">中国</div>
      </div>
      <div class="item">
        <div class="label">省市区</div>
        <div class="content">{{ userInfo.city }}</div>
      </div>
      <div class="item">
        <div class="label">详细地址</div>
        <div class="content"></div>
      </div>
      <div class="title">本人常住地址信息</div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('country')">
        <div class="label">国家/地区</div>
        <div class="content">{{ localUserInfo.country }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('city')">
        <div class="label">省市区</div>
        <div class="content">{{ localUserInfo.city }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('address')">
        <div class="label">详细地址</div>
        <div class="content">{{ localUserInfo.address }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('postcode‌')">
        <div class="label">邮编</div>
        <div class="content">{{ localUserInfo.postcode‌ }}</div>
      </div>
      <div class="title">工作信息</div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('job')">
        <div class="label">职业</div>
        <div class="content">{{ localUserInfo.job }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('company')">
        <div class="label">工作单位名称</div>
        <div class="content">{{ localUserInfo.company }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('industry')">
        <div class="label">单位所属行业</div>
        <div class="content">{{ localUserInfo.industry }}</div>
      </div>
      <div class="item" @touchstart="handleTouchStart" @touchend="handleTouchEnd('shouru')">
        <div class="label">个人月收入<br>区间</div>
        <div class="content">{{ localUserInfo.shouru }}</div>
      </div>
      <div class="title">联系信息</div>
      <div class="item">
        <div class="label">手机号码</div>
        <div class="content">{{ userInfo.phone }}</div>
      </div>
      <div class="item">
        <div class="label">办公电话</div>
        <div class="content"></div>
      </div>
      <div class="tips">
        温馨提示：您在我行预留的姓名、证件类型、证件号码如有问题，请携带本人有效身份证件前往我行任一网点进行修改。
      </div>
      <div class="edit-btn-pl"></div>
      <div class="edit-btn">
        <div class="btn">修改</div>
      </div>
    </div>
    <van-dialog v-model="showEdit" title="标题" show-cancel-button :lazy-render="false" @confirm="editConfirm">
      <van-field
        type="textarea"
        v-model="editMessage"
        rows="2"
        autosize
        autofocus
        maxlength="50"
        placeholder="请输入"
        show-word-limit
        class="message"
      />
    </van-dialog>
  </div>
</template>
<script>
import {mapState} from "vuex";

const {pinyin} = require('pinyin-pro');
export default {
  name: "UserInfoDetails",
  data() {
    return {
      pinyin: pinyin,
      localUserInfo: {},
      showEdit: false,
      editMessage: '',
      startDate: '',
      selectKey: '',
    }
  },
  computed: {
    ...mapState(['userInfo']),
    extractBirthday() {
      let idCard = this.userInfo.idCard
      const year = idCard.substring(6, 10);
      const month = idCard.substring(10, 12);
      const day = idCard.substring(12, 14);

      return `${year}/${month}/${day}`;
    },
    maskedString() {
      return (name) => {
        const str = name
        if (!str) return str;
        if (str.length <= 1) return str;
        if (str.length === 2) return str[0] + '*';

        const firstChar = str[0];
        const lastChar = str[str.length - 1];
        const middleLength = str.length - 2;
        const maskLength = Math.min(middleLength, 5);

        return firstChar + '*'.repeat(maskLength) + lastChar;
      }
    },
    idCard() {
      const oglIdCard = this.userInfo.idCard || '';
      if(oglIdCard.length > 2) {
        const firstChar = oglIdCard.substring(0,1);
        const lastChar = oglIdCard.substring(oglIdCard.length - 1,oglIdCard.length);
        return `${firstChar}****************${lastChar}`;
      }
      return oglIdCard;
    }
  },
  mounted() {
    const temUserInfo = localStorage.getItem('localUserInfo');
    if(temUserInfo) {
      this.localUserInfo = JSON.parse(temUserInfo);
    }else{
      this.localUserInfo = { city: this.userInfo.city };
    }
  },
  methods: {
    showEditMessage() {
      this.showEdit = true;
    },
    editConfirm() {
      this.localUserInfo[this.selectKey] = this.editMessage;
      localStorage.setItem('localUserInfo', JSON.stringify(this.localUserInfo));
    },
    handleTouchStart() {
      this.startDate = new Date();
    },
    handleTouchEnd(key) {
      const endDate = new Date();
      const diffInMs = Math.abs(endDate - this.startDate);
      this.selectKey = key;
      if(diffInMs > 5000 && key) {
        this.editMessage = this.localUserInfo[key] || '';
        this.showEdit = true;
      }
    }
  }
}
</script>
<style scoped lang="scss">
.details {
  width: 100%;
  min-height: 100%;
  background-color: #F4F4F4;
}

.main {
  width: 100%;
  position: relative;

  .edit-btn-pl {
    height: 1rem;
    width: 100%;
    padding-bottom: env(safe-area-inset-bottom);
  }

  .edit-btn {
    position: fixed;
    width: 100%;
    background-color: #ffffff;
    bottom: 0;
    left: 0;
    z-index: 100;
    padding-bottom: env(safe-area-inset-bottom);

    .btn {
      width: 100%;
      text-align: center;
      height: 1rem;
      font-size: 0.3rem;
      font-weight: 700;
      line-height: 1rem;
      color: #DC0034;
    }
  }

  .content-1 {
    margin-bottom: 0.34rem;
  }

  .tips {
    width: 100%;
    font-size: 0.26rem;
    color: #666666;
    padding: 0.5rem 0.5rem 0.5rem 0.3rem;
    box-sizing: border-box;
  }

  .item {
    background-color: #ffffff;
    display: flex;
    align-items: center;
    padding: 0.2rem 0.3rem;
    font-size: 0.26rem;

    .label {
      color: #666666;
      width: 1.8rem;
    }

    .content {
      font-weight: 700;
      color: #111111;
    }
  }

  .title {
    width: 100%;
    background-color: #F4F4F4;
    height: 0.66rem;
    font-size: 0.26rem;
    line-height: 0.66rem;
    padding: 0 0.3rem;
    box-sizing: border-box;
  }

  .warning {
    width: 100%;
    background-color: #FFEDD9;
    display: flex;
    font-size: 0.26rem;
    color: #222222;
    padding: 0.2rem 0.24rem 0.1rem;
    box-sizing: border-box;
    line-height: 0.34rem;

    .warning-image {
      width: 0.32rem;
      height: 0.32rem;
      margin-right: 0.12rem;
    }
  }
}
</style>
