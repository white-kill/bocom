import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class BankDetailDialog extends StatelessWidget {
  const BankDetailDialog({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return showGeneralDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: '银行卡详情',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SafeArea(
          child: Center(child: BankDetailDialog()),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 1.sw - 24.w,
        child: AspectRatio(
          aspectRatio: 1000 / 716,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image(
                  image: 'bank_detail_dialog'.png3x,
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.12,
                  heightFactor: 0.20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
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
