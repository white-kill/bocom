import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter/services.dart';


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
    StackPosition stackPosition = StackPosition(designWidth: 1000, designHeight: 716, deviceWidth: 1.sw);
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
              Positioned(
                right: stackPosition.getX(50),
                top: stackPosition.getY(155),
                child: BaseText(
                  text: AppConfig.config.abcLogic.card1(),
                  fontSize: 16,
                  color: const Color(0xFF757575),
                ),
              ),
              Positioned(
                right: stackPosition.getX(50),
                top: stackPosition.getY(247),
                child: BaseText(
                  text: AppConfig.config.abcLogic.memberInfo.realName,
                  fontSize: 15,
                  color: const Color(0xFF757575),
                ),
              ),
              Positioned(
                right: stackPosition.getX(50),
                top: stackPosition.getY(330),
                child: BaseText(
                  text: AppConfig.config.abcLogic.openOutlets(),
                  fontSize: 15,
                  color: const Color(0xFF757575),
                ),
              ),
              Positioned(
                right: stackPosition.getX(50),
                bottom: stackPosition.getY(50),
                width: 0.4.sw,
                height: stackPosition.getY(100),
                child: Container().withOnTap(onTap: (){
                  Navigator.of(context, rootNavigator: true).pop();
                  Clipboard.setData(ClipboardData(text: AppConfig.config.abcLogic.card1()));
                  '复制成功，去粘贴'.showToast;
                }),
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
