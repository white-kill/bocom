<template>
  <div class="app">
    <nav-bar :title="title+'月账单'">
    </nav-bar>
    <div class="main">
      <van-swipe class="swipe" :show-indicators="false" vertical :loop="false" v-if="details">
        <van-swipe-item class="swipe-item">
          <div class="swipe-item-container">
            <img class="swipe-item-bg" src="@/assets/image/home/bill01.png" alt="">
            <div class="item-content">
              <div class="item-top">
                <div class="item-tooltip" @click="showTooltip"></div>
                <div class="item-amount">{{ formatAmount(details.totalAmount) }}</div>
              </div>
              <div class="chart">
                <div class="chart-pie" ref="chartRefPie1"></div>
              </div>
            </div>
          </div>
        </van-swipe-item>
        <van-swipe-item class="swipe-item">
          <div class="swipe-item-container">
            <img class="swipe-item-bg" src="@/assets/image/home/bill02.png" alt="">
          </div>
        </van-swipe-item>
        <van-swipe-item class="swipe-item">
          <div class="swipe-item-container">
            <img class="swipe-item-bg" v-if="incomeCateogryList.length>0" src="@/assets/image/home/bill06.png" alt="">
            <img class="swipe-item-bg" v-else src="@/assets/image/home/bill03.png" alt="">
            <div class="item-content" v-if="incomeCateogryList.length>0">
              <div class="item-amount">{{ formatAmount(details.cashSurplus) }}</div>
              <div class="item-money">总计 <span>{{ formatAmount(details.income) }}</span></div>
              <div class="chart">
                <div class="chart-pie" ref="chartRefPie2"></div>
              </div>
              <div class="list">
                <div class="list-title">
                  <span>单笔收入排行</span>
                  <!--                  <img class="list-title-icon" src="@/assets/image/home/icon22.png" alt="">-->
                </div>
                <div class="list-item" v-for="(item,index) in incomeCateogryList" :key="index" v-if="index<3">
                  <div class="item-label">{{ item.name }}</div>
                  <div class="item-num">{{ formatAmount(item.totalAmount) }}</div>
                </div>
              </div>
            </div>
          </div>
        </van-swipe-item>
        <van-swipe-item class="swipe-item">
          <div class="swipe-item-container">
            <img class="swipe-item-bg" v-if="expensesCateogryList.length>0" src="@/assets/image/home/bill07.png" alt="">
            <img class="swipe-item-bg" v-else src="@/assets/image/home/bill04.png" alt="">
            <div class="item-content" v-if="expensesCateogryList.length>0">
              <div class="item-money expenses-money">总计 <span>{{ formatAmount(Math.abs(details.expenses)) }}</span></div>
              <div class="chart">
                <div class="chart-pie chart-pie3" ref="chartRefPie3"></div>
              </div>
              <div class="list">
                <div class="list-title">
                  <span>单笔支出排行</span>
                  <!--                  <img class="list-title-icon" src="@/assets/image/home/icon22.png" alt="">-->
                </div>
                <div class="list-item" v-for="(item,index) in expensesCateogryList" :key="index" v-if="index<3">
                  <div class="item-label">{{ item.name }}</div>
                  <div class="item-num">{{ formatAmount(item.totalAmount) }}</div>
                </div>
              </div>
            </div>
          </div>
        </van-swipe-item>
        <van-swipe-item class="swipe-item">
          <div class="swipe-item-container">
            <img class="swipe-item-bg" src="@/assets/image/home/bill05.png" alt="">
          </div>
        </van-swipe-item>
      </van-swipe>
    </div>
    <van-popup v-model="showTooltipFlag" class="analysis-tootip" round position="center" @close="closeTooltip" @click-overlay="closeTooltip">
      <img class="analysis-tootip" src="@/assets/image/home/monthly-bill-tooltip.png" @click="closeTooltip" fit=""></img>
    </van-popup>
  </div>
</template>
<script>
import * as echarts from "echarts";
import {getBillCategory} from "@/api";
import {remToPx, formatAmount} from "@/utils";


export default {
  name: "monthlyBillDetails",
  data() {
    return {
      formatAmount: formatAmount,
      title: this.$route.query.title || 11,
      dateTime: this.$route.query.dateTime,
      details: null,
      incomeCateogryList: [],
      expensesCateogryList: [],
      showTooltipFlag: false
    }
  },
  computed: {
    pieChartOption() {
      const list = [{
        name: '存款',
        value: this.details.totalAmount
      }]
      return {
        legend: {
          bottom: 10,
          left: 'center',
          icon: 'circle',
          itemGap: 20,
          width: remToPx(6.5),
          textStyle: { // 图例文字的样式
            color: '#222222',
            fontSize: remToPx(0.24)
          },
          itemHeight: remToPx(0.16)
        },
        title: [
          {
            text: '￥' + this.formatAmount(this.details.totalAmount), // 主标题
            textStyle: {
              // 主标题样式
              color: '#222222',
              fontWeight: '700',
              fontSize: remToPx(0.28)
            },
            left: 'center', // 定位到适合的位置
            top: 'center', // 定位到适合的位置
          }
        ],
        color: ['#FFB212'],
        series: [
          {
            name: '',
            type: 'pie',
            radius: [55, 70],
            data: list,
            labelLine: {
              show: false
            },
            label: {
              show: false  // 关键：设置为false
            },
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      }
    },
    pieChartOption2() {
      const list = []
      let cateogryList = this.incomeCateogryList
      cateogryList.forEach((item) => {
        const obj = {
          name: item.name,
          value: Math.abs(item.totalAmount)
        }
        list.push(obj)
      })
      return {
        legend: {
          bottom: 10,
          left: 'center',
          icon: 'circle',
          itemGap: 20,
          width: remToPx(6.5),
          textStyle: { // 图例文字的样式
            color: '#222222',
            fontSize: remToPx(0.24)
          },
          itemHeight: remToPx(0.16)
        },
        graphic: {
          elements: [{
            type: 'image',
            style: {
              image: require('@/assets/image/home/decline.png'),
              width: remToPx(0.3),
              height: remToPx(0.3),
            },
            left: '54%', // 定位到适合的位置
            top: remToPx(2.14), // 定位到适合的位置
          }]
        },
        title: [
          {
            text: '较上月', // 主标题
            textStyle: {
              // 主标题样式
              color: '#ACACAC',
              fontWeight: '500',
              fontSize: remToPx(0.24)
            },
            left: '48%', // 定位到适合的位置
            top: remToPx(2.1), // 定位到适合的位置
            subtext: `￥${this.formatAmount(this.details.upIncomeAmount)}`, // 副标题
            subtextStyle: {
              // 副标题样式
              color: '#282828',
              fontSize: remToPx(0.26),
              fontWeight: '700',
            },
            textAlign: 'center' // 主、副标题水平居中显示
          }
        ],
        color: [
          '#DD0035',
          '#FFCCD7',
          '#FF99B0',
          '#FF6688',
          '#FF3360',
          '#B8002C',
          '#930023',
          '#6F001B',
          '#4A0012'
        ],
        series: [
          {
            name: '访问来源',
            type: 'pie',
            radius: [55, 70],
            data: list,
            labelLine: {
              show: false
            },
            label: {
              show: false  // 关键：设置为false
            },

            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      }
    },
    pieChartOption3() {
      const list = []
      let cateogryList = this.expensesCateogryList
      cateogryList.forEach((item) => {
        const obj = {
          name: item.name,
          value: Math.abs(item.totalAmount)
        }
        list.push(obj)
      })
      return {
        legend: {
          bottom: 10,
          left: 'center',
          icon: 'circle',
          itemGap: 20,
          width: remToPx(6.5),
          textStyle: { // 图例文字的样式
            color: '#222222',
            fontSize: remToPx(0.24)
          },
          itemHeight: remToPx(0.16)
        },
        graphic: {
          elements: [{
            type: 'image',
            style: {
              image: require('@/assets/image/home/decline.png'),
              width: remToPx(0.3),
              height: remToPx(0.3),
            },
            left: '54%', // 定位到适合的位置
            top: remToPx(2.66), // 定位到适合的位置
          }]
        },
        title: [
          {
            text: '较上月', // 主标题
            textStyle: {
              // 主标题样式
              color: '#ACACAC',
              fontWeight: '500',
              fontSize: remToPx(0.24)
            },
            left: '48%', // 定位到适合的位置
            top: remToPx(2.6), // 定位到适合的位置
            subtext: `￥${this.formatAmount(this.details.upExpensesAmount)}`, // 副标题
            subtextStyle: {
              // 副标题样式
              color: '#282828',
              fontSize: remToPx(0.26),
              fontWeight: '700',
            },
            textAlign: 'center' // 主、副标题水平居中显示
          }
        ],
        color: ['#0062EE', '#3137FC', '#0055D4', '#002C86', '#CCE1FF', '#66A7FF', '#99C4FF'],
        series: [
          {
            name: '访问来源',
            type: 'pie',
            radius: [55, 70],
            data: list,
            labelLine: {
              show: false
            },
            label: {
              show: false  // 关键：设置为false
            },

            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      }
    }
  },
  mounted() {
    this.getBillCategory()
  },
  methods: {
     showTooltip() {
      this.showTooltipFlag = true
    },
    closeTooltip() {
      this.showTooltipFlag = false
    },
    getBillCategory() {
      getBillCategory({
        dateTime: this.dateTime
      }).then(res => {
        if (res.data.code === 200) {
          this.details = res.data.data
          this.expensesCateogryList = res.data.data.expensesCateogryList
          this.incomeCateogryList = res.data.data.incomeCateogryList

          this.$nextTick(() => {
            let pieEchartsDom = this.$refs.chartRefPie1;
            this.pieChart = echarts.init(pieEchartsDom)
            let pieChart = this.pieChart
            pieChart.setOption(this.pieChartOption)

            let pieEchartsDom2 = this.$refs.chartRefPie2;
            this.pieChart2 = echarts.init(pieEchartsDom2)
            let pieChart2 = this.pieChart2
            pieChart2.setOption(this.pieChartOption2)


            let pieEchartsDom3 = this.$refs.chartRefPie3;
            this.pieChart3 = echarts.init(pieEchartsDom3)
            let pieChart3 = this.pieChart3
            pieChart3.setOption(this.pieChartOption3)
          })
        }
      })
    }
  }
}
</script>
<style scoped lang="scss">
.app {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.main {
  flex: 1;
  width: 100%;
  height: 100px;
  display: flex;
  flex-direction: column;

  .swipe {
    width: 100%;
    height: 100px;
    flex: 1;

    .swipe-item {
      width: 100%;
      height: 100%;

      .swipe-item-container {
        width: 100%;
        height: 100%;
        position: relative;

        .swipe-item-bg {
          position: absolute;
          width: 100%;
          height: 100%;
          top: 0;
          left: 0;
        }

        .item-content {
          position: relative;
          z-index: 2;
          padding-top: 1.3rem;
          box-sizing: border-box;

          .list {
            width: 100%;
            padding: 1rem 0.88rem 0 0.6rem;
            box-sizing: border-box;

            .list-title {
              color: #232323;
              font-size: 0.3rem;
              font-weight: 700;
              display: flex;
              align-items: center;
              justify-content: space-between;
              margin-bottom: 0.3rem;

              .list-title-icon {
                width: 0.12rem;
                height: 0.21rem;
              }
            }

            .list-item {
              display: flex;
              align-items: center;
              justify-content: space-between;
              color: #222222;
              font-size: 0.26rem;
              margin-bottom: 0.3rem;

              .item-num {
                font-size: 0.28rem;
                font-weight: 700;
              }

            }
          }

          .item-top {
            padding-left: 3.3rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }

          .item-tooltip {
            width: 0.5rem;
            height: 0.5rem;
          }

          .item-amount {
            font-size: 0.36rem;
            font-weight: 700;
            box-sizing: border-box;
            padding-right: 0.6rem;
            text-align: right;
          }

          .item-money {
            color: #ABABAB;
            font-size: 0.26rem;
            text-align: right;
            padding-right: 0.6rem;
            box-sizing: border-box;
            margin-top: 1rem;

            span {
              font-size: 0.32rem;
              color: #222222;
              font-weight: 700;
            }
          }

          .expenses-money {
            margin-top: 0;
          }

          .chart {
            width: 100%;

            .chart-pie {
              width: 100%;
              height: 5rem;
              margin-top: 0.5rem;
            }

            .chart-pie3 {
              margin-top: 0;
              height: 6rem;
            }
          }
        }
      }
    }
  }
}

.analysis-tootip {
    width: 6rem;
    height: 4.299rem;
    overflow: hidden;
  }
</style>
