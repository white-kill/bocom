import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_invest_debt_view.dart';
import 'user_invest_info_logic.dart';
import 'user_invest_info_state.dart';

class UserInvestInfoPage extends BaseStateless {
  UserInvestInfoPage({super.key, UserInvestInfoLogic? logic})
      : logic = logic ?? Get.put(UserInvestInfoLogic()),
        super(title: '个人投资者信息维护');

  final UserInvestInfoLogic logic;
  UserInvestInfoState get state => logic.state;

  Future<void> _selectOption({
    required BuildContext context,
    required List<String> options,
    required String initialValue,
    required Key sheetKey,
    required Key pickerKey,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.4,
        child: _InvestOptionSheet(
          options: options,
          initialValue: initialValue,
          sheetKey: sheetKey,
          pickerKey: pickerKey,
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _selectDebts() async {
    final selected = await Get.to<List<String>>(
      () => UserInvestDebtPage(
        initialSelection: state.debts.toList(growable: false),
      ),
    );
    if (selected != null) logic.selectDebts(selected);
  }

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2172, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_user_invest'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            // 收入主要来源
            Positioned(
              left: position.getX(400),
              right: position.getX(120),
              top: position.getY(65),
              child: GestureDetector(
                key: const Key('user-invest-income-source'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectOption(
                  context: context,
                  options: UserInvestInfoLogic.incomeSources,
                  initialValue: state.incomeSource.value,
                  sheetKey: const Key('income-source-sheet'),
                  pickerKey: const Key('income-source-picker'),
                  onSelected: logic.selectIncomeSource,
                ),
                child: Obx(
                  () {
                    final value = state.incomeSource.value;
                    return BaseText(
                      key: const Key('user-invest-income-source-value'),
                      text: value.isEmpty ? '请选择' : value,
                      color: value.isEmpty
                          ? const Color(0xFF999999)
                          : const Color(0xFF181818),
                      fontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
            // 投资人年收入
            Positioned(
              left: position.getX(400),
              right: position.getX(120),
              top: position.getY(195),
              child: GestureDetector(
                key: const Key('user-invest-annual-income'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectOption(
                  context: context,
                  options: UserInvestInfoLogic.annualIncomes,
                  initialValue: state.annualIncome.value,
                  sheetKey: const Key('annual-income-sheet'),
                  pickerKey: const Key('annual-income-picker'),
                  onSelected: logic.selectAnnualIncome,
                ),
                child: Obx(
                  () {
                    final value = state.annualIncome.value;
                    return BaseText(
                      key: const Key('user-invest-annual-income-value'),
                      text: value.isEmpty ? '请选择' : value,
                      color: value.isEmpty
                          ? const Color(0xFF999999)
                          : const Color(0xFF181818),
                      fontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
            // 两年以上投资经验
            Positioned(
              left: position.getX(400),
              right: position.getX(120),
              top: position.getY(350),
              child: GestureDetector(
                key: const Key('user-invest-investment-experience'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectOption(
                  context: context,
                  options: UserInvestInfoLogic.investmentExperiences,
                  initialValue: state.investmentExperience.value,
                  sheetKey: const Key('investment-experience-sheet'),
                  pickerKey: const Key('investment-experience-picker'),
                  onSelected: logic.selectInvestmentExperience,
                ),
                child: Obx(
                  () {
                    final value = state.investmentExperience.value;
                    return BaseText(
                      key: const Key(
                        'user-invest-investment-experience-value',
                      ),
                      text: value.isEmpty ? '请选择' : value,
                      color: value.isEmpty
                          ? const Color(0xFF999999)
                          : const Color(0xFF181818),
                      fontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
            // 尚未偿还的数额较大的债务
            Positioned(
              left: position.getX(400),
              right: position.getX(120),
              top: position.getY(555),
              child: GestureDetector(
                key: const Key('user-invest-debt'),
                behavior: HitTestBehavior.opaque,
                onTap: _selectDebts,
                child: Obx(
                  () {
                    final value = logic.debtDisplayValue;
                    return BaseText(
                      key: const Key('user-invest-debt-value'),
                      text: value.isEmpty ? '请选择' : value,
                      color: value.isEmpty
                          ? const Color(0xFF999999)
                          : const Color(0xFF181818),
                      fontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvestOptionSheet extends StatefulWidget {
  const _InvestOptionSheet({
    required this.options,
    required this.initialValue,
    required this.sheetKey,
    required this.pickerKey,
  });

  final List<String> options;
  final String initialValue;
  final Key sheetKey;
  final Key pickerKey;

  @override
  State<_InvestOptionSheet> createState() => _InvestOptionSheetState();
}

class _InvestOptionSheetState extends State<_InvestOptionSheet> {
  late final FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.options.indexOf(widget.initialValue);
    _selectedIndex = initialIndex < 0 ? 0 : initialIndex;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    setState(() => _selectedIndex = index);
    _controller.animateToItem(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: widget.sheetKey,
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      color: Color(0xFF181818),
                      fontSize: 17,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    widget.options[_selectedIndex],
                  ),
                  child: const Text(
                    '确认',
                    style: TextStyle(
                      color: Color(0xFF0075E8),
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListWheelScrollView(
                  key: widget.pickerKey,
                  controller: _controller,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50,
                  diameterRatio: 100,
                  perspective: 0.0001,
                  useMagnifier: false,
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  children: [
                    for (var index = 0;
                        index < widget.options.length;
                        index++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectIndex(index),
                        child: Center(
                          child: Text(
                            widget.options[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: index == _selectedIndex
                                  ? const Color(0xFF0075E8)
                                  : const Color(0xFF98A2B0),
                              fontSize: 17,
                              fontWeight: index == _selectedIndex
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
