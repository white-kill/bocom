<template>
  <div class="app">
    <nav-bar title="月度账单">
      <div class="nav-title">
        <img class="nav-info" @click="tipsInfo" src="@/assets/image/home/info-icon.png" alt="">
      </div>
    </nav-bar>
    <div class="main">
      <div class="list" v-for="(item, index) in list" :key="index" @click="goDetails(item)">
        <div v-if="item.year" class="title">{{ item.year }}年</div>
        <div class="item">
          <img class="item-bg" :src="monthBg(item.month)" alt="">
          <div class="item-content">
            <div class="item-mooney">
              <div>收入</div>
              <div> ￥{{ formatAmount(item.income.toFixed(2)) }}</div>
            </div>
            <div class="item-mooney">
              <div>支出</div>
              <div> ￥{{ formatAmount(Math.abs(item.expenses).toFixed(2)) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <van-overlay :show="show" @click="show = false">
      <div class="wrapper">
        <div class="block" @click.stop>
          <div class="tips-title">说明</div>
          <div class="tips-content">
            1.月度账单数据是根据您账户的收入、支出等数据信息进行汇总整理而成，仅供参考。具体收入、支出等数据,请以账户内的实际数据信息为准;<br>
            2.月度账单中的资产、收支和理财收益等数据均为截止账单所属月份月末最后一天的数据;<br>
            3.如月底存在尚未入账的信用卡交易，将根据实际记账日期计入下一个月份的月度账单;<br>
            4.如有疑问，请致电我行客服热线95566。
          </div>
          <div class="tips-title tips-btn" @click="show = false">确认</div>
        </div>
      </div>
    </van-overlay>
  </div>
</template>
<script>
import {getMonthBillList} from "@/api";
import { formatAmount } from "@/utils";

export default {
  name: "monthlyBill",
  data() {
    return {
      formatAmount: formatAmount,
      show: false,
      list: []
    }
  },
  computed: {
    monthBg() {
      return (date) => {
        const monthMap = {
          1: require('@/assets/image/home/01.png'),
          2: require('@/assets/image/home/02.png'),
          3: require('@/assets/image/home/03.png'),
          4: require('@/assets/image/home/04.png'),
          5: require('@/assets/image/home/05.png'),
          6: require('@/assets/image/home/06.png'),
          7: require('@/assets/image/home/07.png'),
          8: require('@/assets/image/home/08.png'),
          9: require('@/assets/image/home/09.png'),
          10: require('@/assets/image/home/10.png'),
          11: require('@/assets/image/home/11.png'),
          12: require('@/assets/image/home/12.png'),
        };
        return monthMap[date]
      }
    }
  },
  created() {
    this.getMonthBillList()
  },
  methods: {
    goDetails(item) {
      this.$router.push({
        path:'/monthlyBill/details',
        query:{
          dateTime:item.dateTime,
          title: item.month,
        }
      })
    },
    getMonthBillList() {
      getMonthBillList().then(res => {
        if (res.data.code === 200) {
          this.list = res.data.data
        }
      })
    },
    tipsInfo() {
      this.show = true
    }
  }
}
</script>


<style scoped lang="scss">
.app {
  width: 100%;
  min-height: 100vh;
  background-color: #F4F4F4;
}

.wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.block {
  width: 5.9rem;
  background-color: #fff;
  border-radius: 0.08rem;

  .tips-content {
    font-size: 0.26rem;
    color: #666666;
    line-height: 1.5;
    padding: 0.2rem 0.4rem;
    box-sizing: border-box;
  }

  .tips-title {
    width: 100%;
    height: 0.8rem;
    line-height: 0.8rem;
    font-size: 0.28rem;
    text-align: center;
    font-weight: 700;
    color: #111111;
    border-bottom: 0.01rem solid #F4F4F4;
  }

  .tips-btn {
    color: #DC0034;
    border-bottom: none;
    border-top: 0.01rem solid #F4F4F4;
  }
}

.nav-title {
  width: 100%;
  position: absolute;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 0.3rem;
  box-sizing: border-box;

  .nav-info {
    width: 0.43rem;
    height: 0.43rem;
  }
}

.main {
  width: 100%;
  padding-top: 0.36rem;

  .list {
    width: 100%;
    padding: 0 0.23rem;
    box-sizing: border-box;

    .title {
      color: #9C9C9C;
      font-size: 0.26rem;
      margin-bottom: 0.2rem;
    }

    .item {
      width: 100%;
      height: 2.35rem;
      position: relative;
      margin-bottom: 0.21rem;

      .item-bg {
        width: 100%;
        height: 100%;
        position: absolute;
        left: 0;
        top: 0;
      }

      .item-content {
        width: 100%;
        position: relative;
        display: flex;
        padding: 1.2rem 0 0 0.23rem;

        .item-mooney {
          color: #FFFFFF;
          font-size: 0.3rem;
          line-height: 1.2;
          width: 47%;
        }
      }
    }
  }
}
</style>
