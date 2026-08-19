import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_pages.dart';

// 交易明细未来日期错误面板
// 说明：自定义日期允许先滚动选择，确认时若晚于今日则使用该面板反馈，与原页面交互顺序保持一致。
class TransactionFutureDateDialog extends StatelessWidget {
  const TransactionFutureDateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.43),
      builder: (_) => const TransactionFutureDateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 参考图 1080×2340：错误面板从 y≈1340 开始，内容高约 347w。
      height: 347.w + MediaQuery.paddingOf(context).bottom,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11.w)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned(
                left: 14.w,
                top: 14.w,
                child: Semantics(
                  button: true,
                  label: '关闭错误提示',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF9DA4AD),
                        size: 18.w,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 60.w,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/transaction_detail/future_date_warning.png',
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20.w),
                    Text(
                      '日期数据不能晚于今日',
                      key: const ValueKey('future_date_error_title'),
                      style: TextStyle(
                        color: const Color(0xFF2C2C2C),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 13.w),
                    Container(
                      height: 42.w,
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Semantics(
                        button: true,
                        label: '在线客服',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.toNamed(Routes.customerService);
                          },
                          child: Row(
                            children: [
                              Text(
                                'NAC00029F⌄',
                                style: TextStyle(
                                  color: const Color(0xFFC7CBD2),
                                  fontSize: 13.sp,
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/images/transaction_detail/future_date_service.png',
                                width: 22.w,
                                height: 22.w,
                              ),
                              SizedBox(width: 7.w),
                              Text(
                                '在线客服',
                                style: TextStyle(
                                  color: const Color(0xFF0077DF),
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 15.w,
                child: Semantics(
                  button: true,
                  label: '关闭',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF0077DF), width: 1.w),
                        borderRadius: BorderRadius.circular(11.w),
                      ),
                      child: Text(
                        '关闭',
                        style: TextStyle(
                          color: const Color(0xFF0077DF),
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
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
