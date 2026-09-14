import 'package:bocom/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'account_asset_diary_logic.dart';
import 'account_asset_diary_state.dart';
import 'asset_diary_chart.dart';
import 'asset_diary_date_sheet.dart';

class AccountAssetDiaryPage extends BaseStateless {
  AccountAssetDiaryPage({super.key}) : super(title: '资产日记');

  final AccountAssetDiaryLogic logic = Get.put(AccountAssetDiaryLogic());
  final AccountAssetDiaryState state = Get.find<AccountAssetDiaryLogic>().state;
  static const blue = Color(0xFF0075F6);
  static const grey = Color(0xFF999999);
  String money(double value) => NumberFormat('#,##0.00').format(value);

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Color? get navColor => Colors.white;

  @override
  Color? get background => const Color(0xFFF5F6F8);

  @override
  Widget? get titleWidget => Obx(() => BaseText(
    text: '资产日记', fontSize: 17, fontWeight: FontWeight.w600,
    color: logic.navActionColor.value,
  ));

  @override
  Widget? get leftItem => Row(children: [
    SizedBox(width: 15.w),
    Obx(() => GestureDetector(
      onTap: () => Get.back(),
      child: SizedBox(width: 29.5.w, height: 29.5.w, child: Center(
        child: logic.navActionFlag.value
            ? Image(image: 'nav_back_white'.png, height: 15.w, fit: BoxFit.contain)
            : Image(image: 'nav_back_light_white'.png, width: 29.5.w, height: 29.5.w, fit: BoxFit.contain),
      )),
    )),
  ]);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Function(bool change)? get onNotificationNavChange => logic.onNavChange;

  Future<void> _pickDate(BuildContext context) async {
    final entries = logic.visibleEntries;
    if (entries.isEmpty) return;
    final date = await showModalBottomSheet<DateTime>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .5),
        builder: (_) => AssetDiaryDateSheet(
            dates: entries.map((e) => e.date).toList(),
            initialDate: logic.selectedDate.value));
    if (date != null && context.mounted) logic.selectDate(date);
  }

  void _showDetails(BuildContext context) {
    final amount = logic.amount;
    final date = DateFormat('yyyy-MM-dd').format(logic.selectedDate.value);
    final card = AppConfig.config.abcLogic.cardFour();
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .5),
        builder: (context) => Container(
              height: MediaQuery.sizeOf(context).height * .70,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.w)),
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEDF5FF), Color(0xFFF7F7F7)],
                      stops: [0, .5])),
              child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(children: [
                            SizedBox(height: 13.w),
                            Container(
                                width: 40.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFCDD3DA),
                                    borderRadius: BorderRadius.circular(3.w))),
                            SizedBox(height: 30.w),
                            BaseText(
                                text: date,
                                fontSize: 14,
                                color: const Color(0xFF222222)),
                            SizedBox(height: 7.w),
                            const BaseText(
                                text: '参考资产（元）', fontSize: 14, color: grey),
                            SizedBox(height: 8.w),
                            BaseText(
                                text: money(amount),
                                fontSize: 25,
                                fontWeight: FontWeight.w600),
                            SizedBox(height: 20.w),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: BaseText(
                                    text: '存款+', fontSize: 14, color: grey)),
                            SizedBox(height: 10.w),
                            _card(Padding(
                                padding: EdgeInsets.all(15.w),
                                child: Column(children: [
                                  Row(children: [
                                    const Expanded(
                                        child: BaseText(
                                            text: '活期可用',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    BaseText(
                                        text: money(amount),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)
                                  ]),
                                  SizedBox(height: 18.w),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 16.w),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7F7),
                                          borderRadius:
                                              BorderRadius.circular(7.w)),
                                      child: Row(children: [
                                        Image(image: 'ic_bank_card_logo'.png, width: 15.w, fit: BoxFit.fitWidth,),
                                        // Image.asset(
                                        //     'assets/images/transaction_detail/bank_logo.png',
                                        //     width: 18.w,
                                        //     height: 18.w),
                                        SizedBox(width: 5.w),
                                        Expanded(
                                            child: BaseText(
                                                text: '借记卡 **$card',
                                                fontSize: 16,
                                                color:
                                                    const Color(0xFF333333))),
                                        BaseText(
                                            text: money(amount),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ])),
                                ]))),
                          ])))),
            ));
  }

  Widget _card(Widget child) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(7.w)),
      child: child);

  @override
  Widget initBody(BuildContext context) => Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE5EFFB), Color(0xFFF6F6F6)])),
            child: Obx(() => ListView(
                  padding: EdgeInsets.fromLTRB(
                      15.w,
                      MediaQuery.paddingOf(context).top + navHeight.w + 12.w,
                      15.w,
                      MediaQuery.paddingOf(context).bottom + 30.w),
                  children: [
                    _card(Column(children: [
                      SizedBox(height: 28.w),
                      GestureDetector(
                          onTap: () => _pickDate(context),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BaseText(
                                    text: DateFormat('yyyy年MM月dd日')
                                        .format(logic.selectedDate.value),
                                    fontSize: 14,
                                    color: grey),
                                SizedBox(width: 5.w),
                                Container(
                                    width: 17.w,
                                    height: 17.w,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF2F5FB),
                                        borderRadius:
                                            BorderRadius.circular(7.w)),
                                    child: Icon(Icons.arrow_drop_down,
                                        size: 19.w,
                                        color: const Color(0xFFA1B2CE))),
                              ])),
                      SizedBox(height: 18.w),
                      BaseText(
                          text: money(logic.amount),
                          fontSize: 28,
                          fontWeight: FontWeight.w600),
                      SizedBox(height: 10.w),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 11.w, vertical: 6.w),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(20.w)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFFF861C),
                                    shape: BoxShape.circle)),
                            SizedBox(width: 6.w),
                            const BaseText(
                                text: '资产变动', fontSize: 14, color: grey),
                            SizedBox(width: 8.w),
                            BaseText(
                                text: money(logic.change),
                                fontSize: 17,
                                color: const Color(0xFF333333)),
                          ])),
                      SizedBox(height: 40.w),
                      Padding(
                          padding: EdgeInsets.only(left: 5.w, right: 36.w),
                          child: AssetDiaryChart(
                              entries: logic.visibleEntries,
                              selectedIndex: logic.selectedIndex,
                              showYear: logic.rangeIndex.value == 2,
                              onSelected: logic.selectIndex,
                              onDetails: () => _showDetails(context))),
                      SizedBox(height: 24.w),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              3,
                              (i) => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: GestureDetector(
                                      onTap: () => logic.selectRange(i),
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 5.w),
                                          decoration: BoxDecoration(
                                              color: logic.rangeIndex.value == i
                                                  ? const Color(0xFFE4F0FF)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(20.w)),
                                          child: BaseText(
                                              text: ['近1月', '近3月', '近1年'][i],
                                              fontSize: 14,
                                              color: logic.rangeIndex.value == i
                                                  ? blue
                                                  : const Color(
                                                      0xFF333333))))))),
                      SizedBox(height: 20.w),
                    ])),
                    SizedBox(height: 12.w),
                    _card(Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                                child: BaseText(
                                    text: DateFormat('yyyy-MM-dd')
                                        .format(logic.selectedDate.value),
                                    fontSize: 14,
                                    color: grey)),
                            GestureDetector(
                                onTap: () => showDialog<void>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                            content: const BaseText(
                                                text: '开启后，可对比所选日期与今日的资产金额。'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const BaseText(
                                                      text: '知道了', color: blue))
                                            ])),
                                child: Icon(Icons.info_outline,
                                    color: const Color(0xFF939EAD),
                                    size: 16.w)),
                            SizedBox(width: 4.w),
                            const BaseText(
                                text: '对比今日', fontSize: 14, color: grey),
                            SizedBox(width: 8.w),
                            _DiarySwitch(
                                value: logic.compareToday.value,
                                onChanged: () => logic.compareToday.toggle()),
                          ]),
                          SizedBox(height: 24.w),
                          Row(children: [
                            const Expanded(
                                child: BaseText(
                                    text: '活期可用',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                            BaseText(
                                text: money(logic.amount),
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF555555))
                          ]),
                          if (logic.compareToday.value) ...[
                            SizedBox(height: 14.w),
                            Row(children: [
                              const Expanded(
                                  child: BaseText(
                                      text: '今日', fontSize: 14, color: grey)),
                              BaseText(
                                  text: money(logic.todayAmount),
                                  fontSize: 15,
                                  color: grey)
                            ]),
                            SizedBox(height: 8.w),
                            Row(children: [
                              const Expanded(
                                  child: BaseText(
                                      text: '资产变动', fontSize: 14, color: grey)),
                              BaseText(
                                  text: money(logic.todayAmount - logic.amount),
                                  fontSize: 15,
                                  color: blue)
                            ]),
                          ],
                          SizedBox(height: 27.w),
                          GestureDetector(
                              onTap: () => _showDetails(context),
                              child: const BaseText(
                                  text: '更多资产详情', fontSize: 16, color: blue)),
                          SizedBox(height: 7.w),
                        ]))),
                    SizedBox(height: 30.w),
                    const BaseText(
                        text: '温馨提示：',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: grey),
                    SizedBox(height: 8.w),
                    ...[
                      '1.今日资产数据更新至 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(logic.updatedAt)}。',
                      '2.历史日期的资产为该日24点左右的数据（延期交易资产展示的是次日凌晨02:30时的数据）。若您在凌晨期间产生交易，展示金额可能和实际金额存在偏差。',
                      '3.部分资产的统计口径曾被调整。在统计口径变更日前后，被调整的资产项金额变动可能不连续。',
                      '4.数据仅供参考，不作为对账凭证。',
                    ].map((text) => Padding(
                        padding: EdgeInsets.only(bottom: 8.w),
                        child: BaseText(
                            text: text,
                            fontSize: 14,
                            color: grey,
                            height: 1.6,
                            overflow: TextOverflow.visible))),
                  ],
                )),
      );
}

class _DiarySwitch extends StatelessWidget {
  const _DiarySwitch({required this.value, required this.onChanged});
  final bool value;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
      toggled: value,
      label: '对比今日',
      child: GestureDetector(
          onTap: onChanged,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44.w,
            height: 26.w,
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
                color: value ? const Color(0xFF0075F6) : Colors.white,
                border: Border.all(color: const Color(0xFFCFD3DA)),
                borderRadius: BorderRadius.circular(20.w)),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 2,
                          offset: Offset(0, 1))
                    ])),
          )));
}
