import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class YesterdayIncomeNoteSheet extends StatelessWidget {
  const YesterdayIncomeNoteSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.48),
      builder: (_) => const YesterdayIncomeNoteSheet(),
    );
  }

  static const _content =
      '1、收益统计活期盈、活期富、理财、基金、存款、债券、商业养老金和私募资管产品，其余产品实际产生的收益暂不计入。\n'
      '2、昨日收益为“--”表示最新收益数据尚未生成，因各产品的收益更新时间不同，若部分产品收益未更新，将暂以0元计入。因数据同步延时可能存在展示的收益数据与“我的理财”、“我的基金”等各资产持仓页面中展示的收益数据不一致，此时请以各资产持仓页面展示数据为准。\n'
      '3、收益仅供参考，最终产品投资情况请以产品管理人确认为准。';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.w)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 18.w, 18.w, 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: '关闭收益说明',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F5F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.w,
                        color: const Color(0xFF9DA3AD),
                      ),
                    ),
                  ),
                ),
              ),
              const BaseText(
                text: '温馨提示',
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Color(0xFF252525),
              ),
              SizedBox(height: 13.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 370.w),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: const BaseText(
                    text: _content,
                    fontSize: 14,
                    height: 1.58,
                    maxLines: 1000,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              SizedBox(height: 30.w),
              SizedBox(
                width: double.infinity,
                height: 52.w,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0875ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.w),
                    ),
                  ),
                  child: const BaseText(
                    text: '我知道了',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
