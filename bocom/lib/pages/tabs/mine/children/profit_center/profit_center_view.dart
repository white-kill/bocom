import 'dart:math' as math;
import 'package:bocom/config/app_config.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'profit_center_logic.dart';
import 'profit_center_state.dart';
import '../comprehensive_bill/comprehensive_bill_view.dart';
import '../ledger/ledger_view.dart';

class ProfitCenterPage extends BaseStateless {
  ProfitCenterPage({
    super.key,
    this.initialPeriod = ProfitPeriod.day,
  }) : super(title: '') {
    logic.selectPeriod(initialPeriod);
  }

  final ProfitPeriod initialPeriod;

  final ProfitCenterLogic logic = Get.put(ProfitCenterLogic());
  final ProfitCenterState state = Get.find<ProfitCenterLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get titleWidget => Obx(() => BaseText(
        text: '收益中心',
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: logic.navActionColor.value,
      ));

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 26.w,
              height: 26.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 15.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_back_light'.png,
                        width: 26.w,
                        height: 26.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Obx(
          () => Semantics(
            button: true,
            label: '客服',
            child: SizedBox(
              width: 27.w,
              height: 27.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_kf_white'.png,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_kf_light'.png,
                        width: 27.w,
                        height: 27.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(
              onTap: () => Get.toNamed(Routes.customerService),
            ),
          ),
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionFlag.value = v;
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 897, deviceWidth: 1.sw);
    StackPosition position2 =
        StackPosition(designWidth: 1080, designHeight: 1481, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          key: const Key('profit-center-status-bar-gradient-spacer'),
          width: 1.sw,
          height: statusBarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF267CF0),
                Color(0xFF277AF1),
                Color(0xFF2C79EF),
                Color(0xFF277AF1),
                Color(0xFF287BF2),
                Color(0xFF2A7CF3),
                Color(0xFF2479F2),
                Color(0xFF2C7DF7),
                Color(0xFF317EF4),
                Color(0xFF367DF4),
                Color(0xFF4680F7),
                Color(0xFF4F7FF8),
                Color(0xFF4C81FA),
              ],
              stops: [
                0,
                0.0833,
                0.1667,
                0.25,
                0.3333,
                0.4167,
                0.5,
                0.5833,
                0.6667,
                0.75,
                0.8333,
                0.9167,
                1,
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_profit_center_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position1.getX(200),
              top: position1.getY(180),
              child: Obx(
                () => Row(
                  children: [
                    BaseText(
                      text: logic.amountVisible.value
                          ? AppConfig.config.abcLogic.memberInfo.accountBalance
                              .bankBalance
                          : '****',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Image(
                      image: 'ic_amount_right'.png,
                      width: 5.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: position1.getX(55),
              top: position1.getY(250),
              child: Obx(() => BaseText(
                text: logic.amountVisible.value ?
                    '${AppConfig.config.abcLogic.memberInfo.realName}交行资产更新至${logic.nowDate.value}':'更新至${logic.nowDate.value}',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: const Color(0xFFADCBFF),
              )),
            ),
            Positioned(
              right: position1.getX(0),
              top: position1.getY(180),
              child: SizedBox(
                width: 40.w,
                height: position1.getHeight(100),
              ).withOnTap(onTap: () {
                logic.amountVisible.value = !logic.amountVisible.value;
              }),
            ),
            Positioned(
                left: position1.getX(60),
                top: position1.getY(650),
                child: Row(
                  children: [
                    Container().withOnTap(onTap: () {
                      Get.to(
                        () => ComprehensiveBillPage(initialBillType: 2),
                      );
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(
                        () => LedgerPage(initialLedgerType: 1),
                      );
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(
                        () => ComprehensiveBillPage(initialBillType: 1),
                      );
                    }).expanded(),
                    Container().expanded(),
                  ],
                ).withContainer(
                    width: 1.sw - position1.getX(120),
                    height: position1.getHeight(170))),
          ],
        ),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: position1.getX(40)),
            color: const Color(0xFFF5F5F5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  ProfitPeriodHeader(
                    selectedPeriod: logic.selectedPeriod.value,
                    date: logic.selectedDate.value,
                    onPeriodSelected: logic.selectPeriod,
                    showDateHeader:
                        logic.selectedView.value == ProfitChartView.trend,
                  ),
                  if (logic.selectedView.value == ProfitChartView.trend)
                    Image(
                      image: 'bg_profit_chart'.png3x,
                      width: 1.sw - position1.getX(80),
                      fit: BoxFit.fitWidth,
                    )
                  else
                    ProfitCalendarView(
                      period: logic.selectedPeriod.value,
                      anchor: logic.calendarAnchor.value,
                      selectedDate: logic.selectedDate.value,
                      currentDate: logic.currentDate,
                      canMoveNext: logic.canMoveCalendarNext(
                        logic.selectedPeriod.value,
                      ),
                      onMove: (direction) => logic.moveCalendar(
                        logic.selectedPeriod.value,
                        direction,
                      ),
                      onDaySelected: logic.selectCalendarDay,
                      onWeekSelected: logic.selectCalendarWeek,
                      onMonthSelected: logic.selectCalendarMonth,
                      onYearSelected: logic.selectCalendarYear,
                    ),
                  ProfitViewSwitch(
                    selectedView: logic.selectedView.value,
                    onViewSelected: logic.selectView,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_profit_center_2'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}

class ProfitPeriodHeader extends StatelessWidget {
  const ProfitPeriodHeader({
    super.key,
    required this.selectedPeriod,
    required this.date,
    required this.onPeriodSelected,
    this.showDateHeader = true,
  });

  final ProfitPeriod selectedPeriod;
  final DateTime date;
  final ValueChanged<ProfitPeriod> onPeriodSelected;
  final bool showDateHeader;

  static const _periods = ['日收益', '周收益', '月收益', '年收益'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_periods.length, (index) {
            final period = ProfitPeriod.values[index];
            final selected = period == selectedPeriod;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPeriodSelected(period),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 13.h),
                    BaseText(
                      text: _periods[index],
                      fontSize: 16,
                      fontWeight:
                          selected ? FontWeight.w500 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFF191919)
                          : const Color(0xFF555555),
                    ),
                    SizedBox(height: 9.h),
                    Container(
                      key: selected
                          ? Key('profit-period-selected-${period.name}')
                          : null,
                      width: 29.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF087CFA)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (showDateHeader) ...[
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_left,
                key: const Key('profit-period-previous'),
                size: 26.w,
                color: const Color(0xFFB8BDC4),
              ),
              SizedBox(width: 15.w),
              BaseText(
                text: ProfitCenterLogic.formatPeriodDate(
                  selectedPeriod,
                  date,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF191919),
              ),
              SizedBox(width: 15.w),
              Icon(
                Icons.arrow_right,
                key: const Key('profit-period-next'),
                size: 26.w,
                color: const Color(0xFFB8BDC4),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ProfitViewSwitch extends StatelessWidget {
  const ProfitViewSwitch({
    super.key,
    required this.selectedView,
    required this.onViewSelected,
  });

  final ProfitChartView selectedView;
  final ValueChanged<ProfitChartView> onViewSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132.w,
      height: 38.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Row(
        children: ProfitChartView.values.map((view) {
          final selected = view == selectedView;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onViewSelected(view),
              child: Container(
                key: selected
                    ? Key('profit-view-selected-${view.name}')
                    : null,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(17.w),
                ),
                child: BaseText(
                  text: view == ProfitChartView.calendar ? '日历图' : '走势图',
                  fontSize: 12,
                  color: selected
                      ? const Color(0xFF333333)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProfitCalendarView extends StatelessWidget {
  const ProfitCalendarView({
    super.key,
    required this.period,
    required this.anchor,
    required this.selectedDate,
    required this.currentDate,
    required this.canMoveNext,
    required this.onMove,
    required this.onDaySelected,
    required this.onWeekSelected,
    required this.onMonthSelected,
    required this.onYearSelected,
  });

  final ProfitPeriod period;
  final DateTime anchor;
  final DateTime selectedDate;
  final DateTime currentDate;
  final bool canMoveNext;
  final ValueChanged<int> onMove;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onWeekSelected;
  final ValueChanged<int> onMonthSelected;
  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (period != ProfitPeriod.year)
          _CalendarNavigation(
            title: period == ProfitPeriod.month
                ? '${anchor.year}年'
                : '${anchor.year}年${anchor.month.toString().padLeft(2, '0')}月',
            canMoveNext: canMoveNext,
            onMove: onMove,
            compactBottom: period == ProfitPeriod.month,
          ),
        if (period == ProfitPeriod.day)
          _DayCalendar(
            anchor: anchor,
            selectedDate: selectedDate,
            currentDate: currentDate,
            onSelected: onDaySelected,
          )
        else if (period == ProfitPeriod.week)
          _WeekCalendar(
            anchor: anchor,
            selectedDate: selectedDate,
            currentDate: currentDate,
            onSelected: onWeekSelected,
          )
        else if (period == ProfitPeriod.month)
          _MonthCalendar(
            anchor: anchor,
            selectedDate: selectedDate,
            currentDate: currentDate,
            onSelected: onMonthSelected,
          )
        else
          _YearCalendar(
            selectedDate: selectedDate,
            currentDate: currentDate,
            onSelected: onYearSelected,
          ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _CalendarNavigation extends StatelessWidget {
  const _CalendarNavigation({
    required this.title,
    required this.canMoveNext,
    required this.onMove,
    required this.compactBottom,
  });

  final String title;
  final bool canMoveNext;
  final ValueChanged<int> onMove;
  final bool compactBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12.h,
        bottom: compactBottom ? 4.h : 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CalendarArrow(
            key: const Key('profit-calendar-previous'),
            direction: -1,
            enabled: true,
            onTap: onMove,
          ),
          SizedBox(width: 15.w),
          BaseText(
            text: title,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF191919),
          ),
          SizedBox(width: 15.w),
          _CalendarArrow(
            key: const Key('profit-calendar-next'),
            direction: 1,
            enabled: canMoveNext,
            onTap: onMove,
          ),
        ],
      ),
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({
    super.key,
    required this.direction,
    required this.enabled,
    required this.onTap,
  });

  final int direction;
  final bool enabled;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onTap(direction) : null,
      child: Icon(
        direction < 0 ? Icons.arrow_left : Icons.arrow_right,
        size: 25.w,
        color: enabled ? Colors.black : const Color(0xFFB8BDC4),
      ),
    );
  }
}

class _DayCalendar extends StatelessWidget {
  const _DayCalendar({
    required this.anchor,
    required this.selectedDate,
    required this.currentDate,
    required this.onSelected,
  });

  final DateTime anchor;
  final DateTime selectedDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final days = ProfitCenterLogic.buildMonthCalendar(anchor);
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: BaseText(
                        text: day,
                        fontSize: 13,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8.w,
              crossAxisSpacing: 3.w,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) return const SizedBox.shrink();
              final inMonth = date.month == anchor.month;
              final selected = _sameDay(date, selectedDate);
              final isToday = _sameDay(date, currentDate);
              final hasHistory = inMonth && !date.isAfter(currentDate);
              final selectable = !date.isAfter(currentDate);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: selectable ? () => onSelected(date) : null,
                child: Container(
                  key: selected
                      ? const Key('profit-calendar-day-selected')
                      : null,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFB0B4BC)
                        : hasHistory
                            ? const Color(0xFFF7F7F7)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: BaseText(
                    text: isToday ? '今' : '${date.day}',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : inMonth
                            ? const Color(0xFF555555)
                            : const Color(0xFFBABEC5),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({
    required this.anchor,
    required this.selectedDate,
    required this.currentDate,
    required this.onSelected,
  });

  final DateTime anchor;
  final DateTime selectedDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final weeks = ProfitCenterLogic.buildMonthWeeks(anchor);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: weeks.map((week) {
          final selected = !selectedDate.isBefore(week.start) &&
              !selectedDate.isAfter(week.end);
          final hasHistory = !week.start.isAfter(currentDate);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasHistory ? () => onSelected(week.start) : null,
            child: Container(
              key: selected
                  ? const Key('profit-calendar-week-selected')
                  : null,
              width: double.infinity,
              height: 42.w,
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFB0B4BC)
                    : hasHistory
                        ? const Color(0xFFF7F7F7)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: BaseText(
                text: ProfitCenterLogic.formatCalendarWeek(week),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF333333),
              ),
            ),
          );
        }).toList(),
      ).withContainer(margin: EdgeInsets.only(top: 8.w)),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.anchor,
    required this.selectedDate,
    required this.currentDate,
    required this.onSelected,
  });

  final DateTime anchor;
  final DateTime selectedDate;
  final DateTime currentDate;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 5.w,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final month = index + 1;
          final selected = selectedDate.year == anchor.year &&
              selectedDate.month == month;
          final hasHistory = anchor.year < currentDate.year ||
              (anchor.year == currentDate.year && month <= currentDate.month);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasHistory ? () => onSelected(month) : null,
            child: Container(
              key: selected
                  ? const Key('profit-calendar-month-selected')
                  : null,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFB0B4BC)
                    : hasHistory
                        ? const Color(0xFFF7F7F7)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: BaseText(
                text: '$month月',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          );
        },
      ).withContainer(margin: EdgeInsets.only(top: 10.w, bottom: 5.w)),
    );
  }
}

class _YearCalendar extends StatelessWidget {
  const _YearCalendar({
    required this.selectedDate,
    required this.currentDate,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final DateTime currentDate;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final years = ProfitCenterLogic.buildCalendarYears(currentDate.year);
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: years.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 5.w,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final year = years[index];
          final selected = selectedDate.year == year;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(year),
            child: Container(
              key: selected
                  ? const Key('profit-calendar-year-selected')
                  : null,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFB0B4BC)
                    : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: BaseText(
                text: year == currentDate.year ? '今年' : '$year年',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          );
        },
      ).withContainer(margin: EdgeInsets.only(top: 10.w, bottom: 5.w)),
    );
  }
}

bool _sameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
