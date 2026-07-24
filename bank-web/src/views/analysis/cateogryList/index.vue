<template>
  <div class="app">
    <nav-bar :title="name"></nav-bar>
    <div class="main">
      <div class="header" :style="{ top: (statusBarHeight + appBarHeight) + 'rem' }">
        <div class="header-time">
          <span>{{ dateTime }}</span>
          <img class="header-icon" src="@/assets/image/home/interest.png" alt="" @click="showTooltip">
        </div>
        <div class="total">
          <div class="total-num">共{{ total }}笔交易</div>
          <div class="money">{{
            incomeExpenseType === '2' ? '支出' : '收入'
            }}￥{{ formatAmount(Math.abs(totalAmount).toFixed(2))
              }}
          </div>
        </div>
      </div>
      <div class="header-pl"></div>
      <van-list :immediate-check="false" style="min-height: 80vh" v-model="loading" :finished="finished" :error="error"
        finished-text="没有更多了" @load="nextPages">
        <div class="list">
          <div class="item" v-for="(item, index) in list" :key="index" @click="goDetails(item)">
            <div class="item-time" v-if="item.showTime">{{ convertWeekday(item.transactionTime) }}</div>
            <div class="item-content">
              <img class="item-icon" :src="item.icon" alt="">
              <div class="item-info">
                <div class="item-excerpt">{{ item.excerpt }}</div>
                <div class="item-info-bottom">
                  <div>{{ item.transactionCategory }}({{ item.bankCard }})</div>
                  <div>人民币元 <span>{{ formatAmount(item.amount.toFixed(2)) }}</span></div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </van-list>
      <van-popup v-model="showTooltipFlag" round position="center" @close="closeTooltip" @click-overlay="closeTooltip">
        <div class="tootip" @click="closeTooltip">
          <!-- <img class="tootip-image" src="@/assets/image/home/analysis_tooltip_bg.png" @click="closeTooltip" alt=""></img> -->
          <div class="tootip-content">
            <div>1.收支记录的货币单位为人民币元，外币交易将按照上一日牌价自动折算为人民币；</div>
            <div>2.本人中行卡互转、同名账户跨行互转、信用卡还款、结售汇、投资理财交易，均不计入收入和支出；</div>
            <div>3.您可以在收支记录详情页，设置是否将该笔交易计入收支；</div>
            <div>4.每一笔交易都将按照特征自动分类，您也可以在收支记录详情页修改分类；</div>
            <div>5.您可以对交易添加备注以备查询；</div>
            <div>6.您可以在收支记录列表中删除交易，交易删除后不可恢复，但不会影响账户交易记录；</div>
            <div>7.收支记录的数据更新可能延迟，仅供参考，不作为对账凭证，具体交易信息以账户交易记录为准；</div>
            <div>8.收支记录可查询自2018年1月1日起至今的交易。</div>
          </div>
        </div>
      </van-popup>
    </div>
  </div>

</template>
<script>
import { getBillCategoryList } from "@/api";
import { mapState } from "vuex";
import { formatAmount } from '@/utils'

export default {
  name: "cateogryList",
  data() {
    return {
      formatAmount: formatAmount,
      name: this.$route.query.name || '',
      type: this.$route.query.type || '',
      totalAmount: this.$route.query.totalAmount || '',
      incomeExpenseType: this.$route.query.incomeExpenseType || '',
      dateTime: this.$route.query.dateTime || '',
      status: 'loading',
      pageNum: 1,
      pageSize: 10,
      list: [],
      total: 1,
      loading: false,
      finished: false,
      error: false,
      expensesTotal: 0,
      incomeTotal: 0,
      showTooltipFlag: false,
      lastTime: '',
    }
  },
  created() {
    this.getBillCategoryList()
  },
  computed: {
    ...mapState(['statusBarHeight', 'appBarHeight']),
    convertWeekday() {
      return (str) => {
        const map = {
          'Mon.': '星期一',
          'Mon': '星期一',
          'Tue.': '星期二',
          'Tue': '星期二',
          'Tues.': '星期二',
          'Wed.': '星期三',
          'Wed': '星期三',
          'Thu.': '星期四',
          'Thu': '星期四',
          'Thur.': '星期四',
          'Fri.': '星期五',
          'Fri': '星期五',
          'Sat.': '星期六',
          'Sat': '星期六',
          'Sun.': '星期日',
          'Sun': '星期日'
        };
        return str.replace(/\b(Mon(?:\.)?|Tue(?:\.|s\.)?|Wed(?:\.)?|Thu(?:\.|r\.)?|Fri(?:\.)?|Sat(?:\.)?|Sun(?:\.)?)\b/g, match => map[match]);
      }
    },
  },
  methods: {
    nextPages() {
      if (this.total <= this.list.length) {
        this.finished = true
        return;
      }
      this.pageNum = this.pageNum + 1
      this.loading = true
      this.getBillCategoryList()
    },
    goDetails(item) {
      if (window.FlutterBridge) {
        window.FlutterBridge.postMessage({
          type: 'sz_detail',
          data: JSON.stringify(item.billDetail)
        });
      }
    },
    getBillCategoryList() {
      let formattedDate = ''
      if (this.type === '0') {
        formattedDate = this.dateTime.replace(".", "-");
      } else {
        formattedDate = this.dateTime.replace("年", "");
      }
      getBillCategoryList({
        name: this.name,
        type: this.type,
        incomeExpenseType: this.incomeExpenseType,
        dateTime: formattedDate,
        pageSize: this.pageSize,
        pageNum: this.pageNum,
      }).then(res => {
        if (res.data.code === 200) {
          this.list = [...this.list, ...res.data.data.list]
          this.total = res.data.data.total
          if (this.expensesTotal == 0) {
            this.expensesTotal = res.data.data.expensesTotal
          }
          if (this.incomeTotal == 0) {
            this.incomeTotal = res.data.data.incomeTotal
          }
          // this.pageNum = res.data.data.customizeParam
          this.list.forEach((item, index) => {
            if(index == 0) {
              this.lastTime = item.transactionTime;
              item.showTime = true;
            }else {
              if(item.transactionTime != this.lastTime) {
                this.lastTime = item.transactionTime;
                item.showTime = true;
              }else{
                item.showTime = false;
              }
            }
          });
          this.loading = false
        } else {
          this.loading = false
          this.error = true
        }
      })
    },
    showTooltip() {
      this.showTooltipFlag = true
    },
    closeTooltip() {
      this.showTooltipFlag = false
    }
  }
}
</script>

<style scoped lang="scss">
.app {
  width: 100%;
  min-height: 100vh;
  background-color: #F4F4F4;

  .list {
    width: 100%;

    .item {
      width: 100%;
      color: #222222;

      .item-time {
        line-height: 1;
        margin: 0.18rem 0;
        padding: 0 0.3rem;
        box-sizing: border-box;
        font-size: 0.26rem;
      }

      .item-content {
        width: 7.5rem;
        height: 1.36rem;
        background: #FFFFFF;
        padding: 0.3rem 0.34rem 0 0.3rem;
        box-sizing: border-box;
        display: flex;

        .item-icon {
          width: 0.42rem;
          height: 0.42rem;
        }

        .item-info {
          flex: 1;
          color: #666666;
          margin-left: 0.2rem;
          font-size: 0.26rem;

          .item-excerpt {
            color: #222222;
          }

          .item-info-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;

            span {
              color: #222222;
              font-weight: 700;
            }
          }
        }
      }
    }

  }

  .header-pl {
    width: 100%;
    height: 1.5rem;
  }

  .header {
    width: 100%;
    height: 1.5rem;
    background-color: #ffffff;
    position: fixed;
    left: 0;
    color: #222222;
    font-size: 0.26rem;
    padding: 0.3rem;
    box-sizing: border-box;

    .header-time {
      display: flex;
      align-items: center;
      justify-content: space-between;

      .header-icon {
        width: 0.36rem;
        height: 0.36rem;
      }
    }

    .total {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-top: 0.16rem;

      .money {
        font-size: 0.32rem;
        font-weight: 700;
      }
    }
  }

  .tootip {
    position: relative;
    background-image: url(@/assets/image/home/analysis_tooltip_bg.png);
    width: 6.8rem;
    height: 8.5294rem;
    background-size: contain;
    display: flex;
    justify-content: center;
    // .tootip-image {
    //   width: 6.8rem;
    //   height: 8.5294rem;
    // }

    .tootip-content {
      margin-top: 1.2rem;
      padding: 0 0.5rem;
      width: 100%;
      height: calc(100% - 2.4rem);
      font-size: 0.32rem;
      overflow-y: auto;
      color: #666666;

      div {
        margin-bottom: 0.1rem;
        text-align: justify;
      }
    }
  }
}
</style>
