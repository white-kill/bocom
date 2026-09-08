import 'package:bocom/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import '../print_confim/print_export_repository.dart';

class PrintResendPage extends BaseStateless {
  PrintResendPage({
    super.key,
    required this.record,
  }) : super(title: '重新发送');

  final PrintExportRecord record;

  @override
  Color? get navColor => const Color(0xFFF5F5F5);

  @override
  Color? get background => const Color(0xFFF5F5F5);

  @override
  Widget? get leftItem => Row(
    children: [
      SizedBox(
        width: 15.w,
      ),
      SizedBox(
        width: 30.w,
        height: 30.w,
        child: Center(
          child: Image(
            image: 'nav_back_light_white'.png,
            width: 29.5.w,
            height: 29.5.w,
            fit: BoxFit.contain,
          ),
        ),
      ).withOnTap(onTap: () => Get.back()),
    ],
  );

  @override
  List<Widget>? get rightAction => const [];

  String get _email => record.detail.email;

  @override
  Widget initBody(BuildContext context) {
    final bank = AppConfig.config.abcLogic.memberInfo.bankList.isNotEmpty
        ? AppConfig.config.abcLogic.memberInfo.bankList.first
        : null;
    final bankName = bank?.bankName.isNotEmpty == true
        ? bank!.bankName
        : '交通银行';
    final cardType = bank?.cardType.isNotEmpty == true ? bank!.cardType : '借记卡';
    final cardLastFour = AppConfig.config.abcLogic.cardFour();
    final balance = bank?.accountBalance ?? 0;


    return ListView(
      padding: EdgeInsets.fromLTRB(15.w, 10.w, 15.w, 32.w),
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF969EAC),
            ),
            children: const [
              TextSpan(text: '将重新发送至以下邮箱，还可重发 '),
              TextSpan(
                text: '4',
                style: TextStyle(color: Color(0xFFF29A55)),
              ),
              TextSpan(text: ' 次'),
            ],
          ),
        ),
        SizedBox(height: 15.w),
        Container(
          key: const Key('print-resend-email'),
          height: 60.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Row(
            children: [
              const BaseText(
                text: '电子邮箱',
                fontSize: 16,
                color: Color(0xFF222222),
              ),
              SizedBox(width: 22.w),
              Expanded(
                child: BaseText(
                  text: _email,
                  fontSize: 16,
                  color: const Color(0xFF454545),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.w),
        const BaseText(
          text: '通过该银行卡进行身份验证',
          fontSize: 14,
          color: Color(0xFF969EAC),
        ),
        SizedBox(height: 15.w),
        Container(
          key: const Key('print-resend-bank-card'),
          padding: EdgeInsets.fromLTRB(16.w, 20.w, 14.w, 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BaseText(
                text: '银行卡',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181818),
              ),
              SizedBox(height: 25.w),
              Row(
                children: [
                  Image.asset(
                    'assets/images/transaction_detail/bank_logo.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText(
                          text: '$bankName $cardType(**$cardLastFour)',
                          fontSize: 18,
                          color: const Color(0xFF282828),
                          maxLines: 1,
                        ),
                        SizedBox(height: 5.w),
                        BaseText(
                          text: '可用余额：$balance元',
                          fontSize: 15,
                          color: const Color(0xFF969EAC),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF5D626A),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 35.w),
        Container(
          key: const Key('print-resend-submit'),
          height: 48.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0878E8),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: const BaseText(
            text: '重新发送',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
