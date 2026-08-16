import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'ledger_edit_logic.dart';
import 'ledger_edit_state.dart';

class LedgerEditPage extends BaseStateless {
  LedgerEditPage({super.key}) : super(title: '');

  static const String routeName = 'LedgerEditPage';

  final LedgerEditLogic logic = Get.put(LedgerEditLogic());
  final LedgerEditState state = Get.find<LedgerEditLogic>().state;

  @override
  bool get isShowAppBar => false;

  @override
  Widget initBody(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    StackPosition stackPosition = StackPosition(
      designWidth: 1080,
      designHeight: 2376,
      deviceWidth: 1.sw,
    );
    return GetBuilder<LedgerEditLogic>(
      id: 'image',
      builder: (_) {
        final imageName = LedgerEditLogic.imageNames[state.imageIndex];
        return ListView(
          padding: EdgeInsets.only(bottom: bottomInset),
          children: [
            Stack(
              children: [
                Image(
                  image: imageName.png,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                  gaplessPlayback: true,
                ),
                Positioned(
                  left: 0.w,
                  top: 35.h,
                  child: SizedBox(
                    width: 60.w,
                    height: 30.h,
                  ).withOnTap(onTap: () => logic.back()),
                ),
                // 日期
                Positioned(
                  right: stackPosition.getX(120),
                  top: stackPosition.getY(912),
                  child: BaseText(
                    text: _todayText(),
                    fontSize: 15,
                    color: const Color(0xFF000000),
                  ),
                ),
                Positioned(
                  left: 60.w,
                  top: 35.h,
                  child: SizedBox(
                    width: 1.sw - 120.w,
                    height: 33.h,
                    child: Row(
                      children: [
                        Container().withOnTap(onTap: () {
                          logic.switchImage(0);
                        }).expanded(),
                        Container().withOnTap(onTap: () {
                          logic.switchImage(1);
                        }).expanded(),
                      ],
                    ),
                  ),
                ),
                // 输入金额的输入框
                Positioned(
                  left: stackPosition.getX(82),
                  right: stackPosition.getX(82),
                  top: stackPosition.getY(435),
                  child: _amountField(stackPosition),
                ),
                // 输入备注的输入框
                Positioned(
                  left: stackPosition.getX(140),
                  right: stackPosition.getX(85),
                  top: stackPosition.getY(1645),
                  child: _remarkField(stackPosition),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _amountField(StackPosition position) {
    final focused = logic.amountFocusNode.hasFocus;
    final hasText = logic.amountController.text.isNotEmpty;
    return Container(
      height: position.getHeight(160),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: position.getWidth(98),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BaseText(
                          text: '¥',
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF303030),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: logic.amountController,
                        focusNode: logic.amountFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onSubmitted: (_) =>
                            logic.remarkFocusNode.requestFocus(),
                        style: TextStyle(
                          fontSize: 32.sp,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF303640),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            right: focused && hasText ? 42.w : 0,
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 28.sp,
                            height: 1,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFFD5D9DF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (focused && hasText)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: logic.clearAmount,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Icon(
                          Icons.cancel,
                          size: 18.w,
                          color: const Color(0xFFC5CAD2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: focused ? 1.5.w : 1.w,
            color: focused ? const Color(0xFF1677FF) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  String _todayText() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '今天 ${now.year}年${month}月${day}日';
  }

  Widget _remarkField(StackPosition position) {
    return Container(
      height: position.getHeight(270),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: position.getHeight(45),
            child: TextField(
              controller: logic.remarkController,
              focusNode: logic.remarkFocusNode,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              maxLength: 24,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 20.sp,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.w),
                hintText: '备注更多信息（24个字）',
                hintStyle: TextStyle(
                  fontSize: 17.sp,
                  color: const Color(0xFFB8BDC6),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: BaseText(
              text: '${logic.remarkController.text.characters.length}/24',
              fontSize: 14,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
