<template>
  <div class="app">
    <nav-bar title="收支分析"></nav-bar>
    <div class="main">
      <div class="title">
        <div class="item" @click="datePopup">
          <span>{{ dateTime }}</span>
          <img class="icon" src="@/assets/image/home/arrow-tri-down.png" alt />
        </div>
        <div class="item" @click="selectBankShow = true">
          <span>{{ bankName }}</span>
          <img class="icon" src="@/assets/image/home/arrow-tri-down.png" alt />
        </div>
        <div class="date">
          <div @click="changeType('1')" :class="['date-item', type === '1' ? 'date-item-month' : '']">年</div>
          <div @click="changeType('0')" :class="['date-item', type === '0' ? 'date-item-month' : '']">月</div>
        </div>
      </div>
      <div class="analysis">
        <img class="analysis-bg" v-if="incomeExpenseType === '2'" src="@/assets/image/home/budgetAnalysis1.png" alt />
        <img class="analysis-bg" v-if="incomeExpenseType === '1'" src="@/assets/image/home/budgetAnalysis2.png" alt />
        <div class="analysis-content" v-if="analysisDetails">
          <div class="analysis-title">
            <div :class="['item', incomeExpenseType === '2' ? 'active' : '']" @click="changeIncomeExpenseType('2')">
              <div>支出</div>
              <div>￥{{ formatAmount(Math.abs(analysisDetails.expenses).toFixed(2)) }}</div>
            </div>
            <div :class="['item', incomeExpenseType === '1' ? 'active' : '']" @click="changeIncomeExpenseType('1')">
              <div>收入</div>
              <div>￥{{ formatAmount(analysisDetails.income.toFixed(2)) }}</div>
            </div>
          </div>
          <div class="chart">
            <div class="chart-line" ref="chartRef"></div>
            <div class="chart-pie" v-if="cateogryList.length > 0" ref="chartRefPie"></div>
            <div v-else class="empty">
              <img class="empty-bg" src="@/assets/image/home/empty.png" alt />
              <span>{{ type === '0' ? '本月暂无交易' : '本年暂无交易' }}</span>
            </div>
          </div>
        </div>
      </div>
      <div class="cateogry-list" v-if="analysisDetails && cateogryList.length > 0">
        <div class="cateogry-title">
          <span>{{ incomeExpenseType === '2' ? '支出' : '收入' }}</span>
          <span>
            ￥{{
              incomeExpenseType === '2' ? formatAmount(Math.abs(analysisDetails.expenses)) :
                formatAmount(Math.abs(analysisDetails.income))
            }}
          </span>
        </div>
        <div class="item" v-for="(item, index) in cateogryList" :key="index" @click="goCateogryList(item)">
          <img class="item-icon" :src="item.categoryIcon" alt />
          <div class="item-content">
            <div class="item-content-info">
              <div class="item-name">{{ item.name }} {{ item.rate }}%</div>
              <div class="item-number">￥{{ formatAmount(Math.abs(item.totalAmount)) }}</div>
            </div>
            <div class="item-progress">
              <van-progress :show-pivot="false" :percentage="item.rate" stroke-width="0.08rem"
                :color="incomeExpenseType === '2' ? expenseColorList[index] : incomeColorList[index]" />
            </div>
          </div>
        </div>
      </div>
    </div>
    <select-bank-card-pop @close="selectBankShow = false" @confirm="bankConfirm"
      :show="selectBankShow"></select-bank-card-pop>
    <van-popup v-model="yearMonthShow" position="bottom" @close="yearMonthShow = false">
      <van-datetime-picker v-model="currentDate" type="year-month" :min-date="minDate" :max-date="maxDate"
        :formatter="formatter" @cancel="yearMonthShow = false" @confirm="yearMonthConfirm" />
    </van-popup>
    <van-popup v-model="yearShow" round position="bottom">
      <van-picker show-toolbar :default-index="9" :columns="columns" @cancel="yearShow = false" @confirm="yearConfirm" />
    </van-popup>
  </div>
</template>
<script>
import * as echarts from "echarts";
import { getBillAnalysis } from "@/api";
import { remToPx, formatAmount } from "@/utils";

export default {
  name: "analysis",
  data() {
    return {
      pickerValue: ['2025年'],
      formatAmount: formatAmount,
      yearMonthShow: false,
      dateTime: "",
      type: "0",
      minDate: new Date(2020, 0, 1),
      maxDate: new Date(),
      currentDate: new Date(),
      currentYear: "",
      yearShow: false,
      analysisDetails: null,
      selectBankShow: false,
      currentClickedIndex: null,
      bankName: "全部账户",
      incomeExpenseType: "2", // 1收入 2支出
      expenseColorList: [
        "#0062EE",
        "#3137FC",
        "#0055D4",
        "#002C86",
        "#CCE1FF",
        "#66A7FF",
        "#99C4FF"
      ],
      incomeColorList: [
        "#DD0035",
        "#FFCCD7",
        "#FF99B0",
        "#FF6688",
        "#FF3360",
        "#B8002C",
        "#930023",
        "#6F001B",
        "#4A0012"
      ]
    };
  },
  mounted() {
    this.initDate();
    this.getBillAnalysis();
  },
  computed: {
    cateogryList() {
      return this.incomeExpenseType === "2"
        ? this.analysisDetails.expensesCateogryList
        : this.analysisDetails.incomeCateogryList;
    },
    columns() {
      const currentYear = new Date().getFullYear();
      const lastEightYears = [];
      for (let i = 0; i < 9; i++) {
        lastEightYears.push(`${currentYear - i}年`);
      }
      return lastEightYears.reverse();
    },
    tooltipBgColor() {
      return this.incomeExpenseType === "2" ? "#2C70ED" : "#DD0035";
    },
    lineChartOption() {
      let trendList = this.analysisDetails.trendList;
      const reversedTrendList = [...trendList].reverse();
      const incomeList = trendList.map(item => item.income).reverse(); // 收入
      const expensesList = trendList
        .map(item => Math.abs(item.expenses))
        .reverse(); // 支出
      let tooltipBgColor = this.tooltipBgColor;
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const isFutureDate = dateTime => {
        const date = new Date(dateTime);
        if (this.type === "0") {
          const pointDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
          return pointDate > today;
        }
        const currentMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const pointMonth = new Date(date.getFullYear(), date.getMonth(), 1);
        return pointMonth > currentMonth;
      };
      const valueList =
        this.incomeExpenseType === "2" ? expensesList : incomeList;
      const borderColor =
        this.incomeExpenseType === "2" ? "#2C70ED" : "#DD0035";
      const firstFutureIndex = reversedTrendList.findIndex(item =>
        isFutureDate(item.dateTime)
      );
      const pastSeriesData = valueList.map((value, index) => {
        if (firstFutureIndex !== -1 && index >= firstFutureIndex) {
          return "-";
        }
        return {
          value,
          itemStyle: {
            color: "#fff",
            borderColor,
            borderWidth: 2
          }
        };
      });
      const futureSeriesData = valueList.map((value, index) => {
        if (firstFutureIndex === -1 || index < firstFutureIndex - 1) {
          return "-";
        }
        return {
          value,
          symbol: "none",
          itemStyle: {
            color: "transparent",
            borderColor: "transparent",
            borderWidth: 0
          }
        };
      });
      const dateTimeList = trendList.map(item => {
        const date = new Date(item.dateTime);
        if (this.type === "0") {
          return `${date.getMonth() + 1}-${date.getDate()}`;
        }
        return `${date.getMonth() + 1}月`;
      });
      return {
        tooltip: {
          trigger: "axis",
          position: function (point, params, dom, rect, size) {
            const chartTop = 20;
            return [point[0], chartTop];
          },
          backgroundColor: "transparent", // 背景透明
          borderWidth: 0, // 边框宽度设为0
          padding: 0, // 内边距设为0
          alwaysShowContent: false, // 注意这里设为 false
          // 使用 formatter 返回 HTML 内容
          formatter: params => {
            let name, value;
            params.forEach(element => {
              const list = element.name.split("-");
              if (list.length >= 2) {
                name = `${list[0] > 9 ? list[0] : "0" + list[0]}月${list[1] > 9 ? list[1] : "0" + list[1]
                  }日`;
                value = element.value;
              } else {
                name = element.name;
                value = element.value;
              }
            });
            if(this.type == '1')name = `${this.dateTime}年${name}`
            return `
                        <div style="
          width: 1.39rem;
          height: 0.93rem;
          background: ${this.tooltipBgColor};
          border: 0.02rem solid #fff;
          border-radius: 0.08rem;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          color: white;
          font-size: 0.2rem;
        ">
                            <div>${name}</div>
                            <div>￥${value && value != '-' ? formatAmount(value?.toFixed(2)):'0.00'}</div>
                        </div>
                    `;
          },
          confine: true,
          extraCssText: "box-shadow: 0 0 10px rgba(0,0,0,0.3);"
        },
        grid: {
          left: remToPx(0.2),
          right: remToPx(0.3),
          bottom: remToPx(0.2)
        },
        xAxis: {
          type: "category",
          data: dateTimeList.reverse(),
          axisLine: {
            lineStyle: {
              color: "#C1C1C1"
            }
          },
          axisTick: {
            lineStyle: {
              color: "#C1C1C1"
            }
          },
          axisLabel: {
            interval: this.type === "1" ? 0 : "auto",
            formatter: value => {
              if (this.type !== "1") {
                return value;
              }
              const month = parseInt(value, 10);
              return [1, 3, 6, 9, 12].includes(month) ? value : "";
            }
          }
        },
        yAxis: {
          type: "value",
          show: false // 隐藏Y轴
        },
        series: [
          {
            data: pastSeriesData,
            type: "line",
            symbol: "circle",
            symbolSize: 3,
            lineStyle: {
              width: 2,
              type: "solid",
              color: borderColor
            }
          },
          ...(firstFutureIndex !== -1
            ? [
                {
                  data: futureSeriesData,
                  type: "line",
                  symbol: "none",
                  symbolSize: 3,
                  lineStyle: {
                    width: 2,
                    type: "solid",
                    color: "transparent"
                  },
                  tooltip: {
                    show: false
                  }
                }
              ]
            : [])
        ]
      };
    },

    pieChartOption() {
      const list = [];
      let cateogryList =
        this.incomeExpenseType === "2"
          ? this.analysisDetails.expensesCateogryList
          : this.analysisDetails.incomeCateogryList;
      let upTotalAmount = this.incomeExpenseType === "2" ? Math.abs(this.analysisDetails.upExpenses) : Math.abs(this.analysisDetails.upIncome);
      let image = require("@/assets/image/home/down.png");
      if((this.incomeExpenseType === "2" && this.analysisDetails.upExpenses > 0) || this.incomeExpenseType === "1" && this.analysisDetails.upIncome > 0) {
        image = require("@/assets/image/home/up.png");
      }
      cateogryList.forEach(item => {
        const obj = {
          name: item.name,
          value: Math.abs(item.totalAmount)
        };
        list.push(obj);
      });
      return {
        grid: {
          bottom: "5%"
        },
        legend: {
          bottom: 10,
          left: "center",
          icon: "circle",
          itemGap: 20,
          width: remToPx(6.5),
          textStyle: {
            // 图例文字的样式
            color: "#222222",
            fontSize: remToPx(0.24)
          },
          itemHeight: remToPx(0.16)
        },
        graphic: {
          elements: [
            {
              type: "image",
              style: {
                image: image,
                width: remToPx(0.28),
                height: remToPx(0.25)
              },
              left: "55%", // 定位到适合的位置
              top: remToPx(2.19) // 定位到适合的位置
            }
          ]
        },
        title: [
          {
            text: this.type === "0" ? "较上月" : "较上年", // 主标题
            textStyle: {
              // 主标题样式
              color: "#ACACAC",
              fontWeight: "500",
              fontSize: remToPx(0.24)
            },
            left: "48%", // 定位到适合的位置
            top: remToPx(2.1), // 定位到适合的位置
            subtext: `￥${formatAmount(upTotalAmount)}`, // 副标题
            subtextStyle: {
              // 副标题样式
              color: "#282828",
              fontSize: remToPx(0.26),
              fontWeight: "700"
            },
            textAlign: "center" // 主、副标题水平居中显示
          }
        ],
        color:
          this.incomeExpenseType === "2"
            ? this.expenseColorList
            : this.incomeColorList,
        series: [
          {
            name: "访问来源",
            type: "pie",
            radius: [50, 70],
            center: ["50%", "45%"],
            data: list,
            // labelLine: {
            //   show: false
            // },
            // label: {
            //   show: false // 关键：设置为false
            // },
            label: {
              show: false,
              emphasis: {
                show: true
              },
              position: 'outside',  // 关键：必须为 'outside'
              formatter: '{b}\n{d}%',  // 换行显示
              fontSize: remToPx(0.24),
              fontWeight: 'normal',
              color: '#333',
              lineHeight: remToPx(0.32),
              padding: [0, -60, 35, -60],
              rich: {
                icon: {
                  fontSize: 16
                },
                name: {
                  fontSize: 14,
                  padding: [0, 10, 0, 4],
                  color: '#666666'
                },
                value: {
                  fontSize: 18,
                  fontWeight: 'bold',
                  color: '#333333'
                }
              }
            },
            labelLine: {
              show: false,
              emphasis: {
                show: true
              },
              length: 20,
              length2: 100,
              smooth: 0.2,
              distance: 10,   // 标签距离图形边缘的距离，值越大线越长
              lineStyle: {
                color: '#666',
                width: 1.5,
                type: 'solid'
              }
            },
            // emphasis: {
            //   itemStyle: {
            //     shadowBlur: 10,
            //     shadowOffsetX: 0,
            //     shadowColor: "rgba(0, 0, 0, 0.5)"
            //   }
            // }
          }
        ]
      };
    }
  },

  methods: {
    getLastPastDataIndex() {
      const pastData = this.lineChartOption.series[0].data;
      for (let i = pastData.length - 1; i >= 0; i--) {
        if (pastData[i] !== "-") {
          return i;
        }
      }
      return pastData.length - 1;
    },
    goCateogryList(item) {
      this.$router.push({
        path: `/analysis/cateogryList`,
        query: {
          name: item.name,
          type: this.type,
          incomeExpenseType: this.incomeExpenseType,
          dateTime: this.dateTime,
          totalAmount: item.totalAmount
        }
      });
    },
    changeIncomeExpenseType(type) {
      if (type === this.incomeExpenseType) return;
      this.incomeExpenseType = type;
      let chart = this.chart;
      chart.setOption(this.lineChartOption);
      chart.dispatchAction({
        type: "hideTip"
      });
      const lastIndex = this.getLastPastDataIndex();
      chart.dispatchAction({
        type: "showTip",
        seriesIndex: 0,
        dataIndex: lastIndex
      });
      let pieChart = this.pieChart;
      pieChart.setOption(this.pieChartOption);
    },
    bankConfirm(name) {
      this.bankName = name;
    },
    initDate() {
      if (this.type === "0") {
        if (this.currentYear) {
          let yearString = Number(this.currentYear.replace("年", ""));
          let date = new Date(yearString, 1);
          let year = date.getFullYear();
          let month = String(date.getMonth()).padStart(2, "0");
          this.dateTime = `${year}.${month}`;
        } else {
          let date = this.currentDate;
          let year = date.getFullYear();
          let month = String(date.getMonth() + 1).padStart(2, "0");
          this.dateTime = `${year}.${month}`;
          this.currentYear = `${year}年`;
        }
      } else {
        this.dateTime = `${this.currentDate.getFullYear()}`;
      }
    },
    yearConfirm(value) {
      this.currentYear = `${value}`;
      this.dateTime = `${value}`;
      let year = Number(this.currentYear.replace("年", ""));
      this.currentDate = new Date(year, 1);
      this.yearShow = false;
      this.getBillAnalysis();
    },
    yearMonthConfirm(value) {
      this.currentDate = value;
      this.yearMonthShow = false;
      let year = value.getFullYear();
      let month = String(value.getMonth() + 1).padStart(2, "0");
      this.dateTime = `${year}.${month}`;
      this.getBillAnalysis();
    },
    datePopup() {
      if (this.type === "0") {
        this.yearMonthShow = true;
      } else {
        this.yearShow = true;
      }
    },
    formatter(type, val) {
      if (type === "year") {
        return `${val}年`;
      } else if (type === "month") {
        return `${val}月`;
      }
      return val;
    },
    // 切换年月
    changeType(type) {
      if (type === this.type) return;
      this.type = type;
      this.initDate();
      this.getBillAnalysis();
    },
    getBillAnalysis() {
      let formattedDate = "";
      if (this.type === "0") {
        formattedDate = this.dateTime.replace(".", "-");
      } else {
        formattedDate = this.dateTime.replace("年", "");
      }
      getBillAnalysis({
        dateTime: formattedDate,
        type: this.type
      }).then(res => {
        if (res.data.code === 200) {
          this.analysisDetails = res.data.data;
          this.analysisDetails.trendList = this.analysisDetails.trendList.reverse()
          this.$nextTick(() => {
            let echartsDom = this.$refs.chartRef;
            this.chart = echarts.init(echartsDom);
            let chart = this.chart;
            chart.setOption(this.lineChartOption);

            let pieEchartsDom = this.$refs.chartRefPie;
            this.pieChart = echarts.init(pieEchartsDom);
            let pieChart = this.pieChart;
            pieChart.setOption(this.pieChartOption);

            // 页面加载完成后显示最后一个点的 tooltip
            setTimeout(() => {
              const lastIndex = this.getLastPastDataIndex();
              this.chart.dispatchAction({
                type: "showTip",
                seriesIndex: 0, // 系列索引
                dataIndex: lastIndex // 数据索引（最后一个有效点）
              });
              // 绑定点击事件
              // this.pieChart.on('click', (params) => {
              //   if (params.componentType === 'series') {
              //     this.handlePieClick(params);
              //   }
              // });
            }, 100);
          });
        }
      });
    },
    handlePieClick(params) {
      // 获取原始数据
      const originalData = this.incomeExpenseType === "2"
        ? this.analysisDetails.expensesCateogryList
        : this.analysisDetails.incomeCateogryList;

      // 构建新数据
      const newData = originalData.map((item, index) => {
        const baseItem = {
          name: item.name,
          value: Math.abs(item.totalAmount)
        };

        if (index === params.dataIndex) {
          return {
            ...baseItem,
            label: {
              show: true,
              position: 'outside',  // 关键：必须为 'outside'
              formatter: '{b}\n{d}%',  // 换行显示
              fontSize: remToPx(0.24),
              fontWeight: 'normal',
              color: '#333',
              lineHeight: remToPx(0.32),
              padding: [0, -60, 35, -60],
              rich: {
                icon: {
                  fontSize: 16
                },
                name: {
                  fontSize: 14,
                  padding: [0, 10, 0, 4],
                  color: '#666666'
                },
                value: {
                  fontSize: 18,
                  fontWeight: 'bold',
                  color: '#333333'
                }
              }
            },
            labelLine: {
              show: true,
              length: 20,
              length2: 120,
              smooth: 0.2,
              lineStyle: {
                color: '#666',
                width: 1.5,
                type: 'solid'
              }
            }
          };
        }

        return baseItem;
      });

      // 更新图表
      this.pieChart.setOption({
        series: [{
          data: newData,
          label: { show: false },
          labelLine: { show: false },
          // 确保饼图的配置
          avoidLabelOverlap: true,  // 避免标签重叠
          labelLayout: {
            hideOverlap: true
          }
        }]
      });

      this.currentClickedIndex = params.dataIndex;
    },
  }
};
</script>
<style scoped lang="scss">
.app {
  width: 100%;
  min-height: 100vh;
  background-color: #f4f4f4;
}

.main {
  width: 100%;

  .cateogry-list {
    width: 7.1rem;
    background: #ffffff;
    border-radius: 0.16rem;
    margin: 0.3rem auto 0.5rem;
    padding-bottom: 0.5rem;

    .item {
      width: 100%;
      display: flex;
      align-items: center;
      padding: 0 0.3rem 0 0.24rem;
      box-sizing: border-box;
      margin-bottom: 0.3rem;

      .item-content {
        flex: 1;
        font-size: 0.26rem;
        color: #222222;
        margin-left: 0.24rem;

        .item-progress {
          width: 4.58rem;
          margin-top: 0.1rem;
        }

        .item-content-info {
          display: flex;
          justify-content: space-between;
        }
      }

      .item-number {
        font-size: 0.32rem;
        color: #282828;
        font-weight: 700;
      }

      .item-icon {
        width: 0.6rem;
        height: 0.6rem;
      }
    }

    .cateogry-title {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.24rem 0.3rem 0 0.24rem;
      box-sizing: border-box;
      margin-bottom: 0.3rem;

      span {
        font-size: 0.3rem;
        font-weight: bold;
        color: #222222;

        &:last-child {
          font-size: 0.32rem;
        }
      }
    }
  }

  .analysis {
    width: 7.14rem;
    height: 11.92rem;
    position: relative;
    margin: 0.32rem auto 0;

    .analysis-bg {
      width: 100%;
      height: 100%;
      position: absolute;
      top: 0;
      left: 0;
    }

    .analysis-content {
      position: relative;

      .chart {
        width: 100%;

        .empty {
          width: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          font-size: 0.256rem;
          padding-top: 1.5rem;
          color: #666666;

          .empty-bg {
            width: 1.8rem;
            height: 1.8rem;
            margin-bottom: 0.5rem;
          }
        }

        .chart-line {
          width: 100%;
          height: 3rem;
        }

        .chart-pie {
          width: 100%;
          height: 5.4rem;
          margin-top: 0.5rem;
        }
      }

      .analysis-title {
        width: 100%;
        display: flex;
        padding-top: 0.7rem;
        margin-bottom: 1rem;

        .item {
          width: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-direction: column;
          font-size: 0.34rem;
          line-height: 1.5;
          font-weight: 700;
          color: #999;
        }

        .active {
          font-weight: 700;
          color: #222222;
        }
      }
    }
  }

  .title {
    display: flex;
    align-items: center;
    width: 100%;
    background-color: #ffffff;
    color: #222222;
    font-size: 0.24rem;
    padding: 0.24rem 0.42rem;
    font-weight: bold;
    box-sizing: border-box;

    .item {
      margin-right: 0.56rem;
    }

    .date {
      width: 1.26rem;
      height: 0.5rem;
      overflow: hidden;
      border-radius: 0.25rem;
      border: 0.02rem solid #2c70ed;
      box-sizing: border-box;
      margin-left: auto;
      display: flex;

      .date-item {
        width: 50%;
        height: 100%;
        display: flex;
        align-items: center;
        color: #2b71eb;
        justify-content: center;

        &.date-item-month {
          background-color: #2b71eb;
          color: #fff;
        }
      }
    }

    .icon {
      width: 0.14rem;
      height: 0.1rem;
      margin-left: 0.08rem;
    }
  }
}
</style>
