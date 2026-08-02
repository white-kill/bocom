import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'mine_logic.dart';
import 'mine_state.dart';

class MinePage extends BaseStateless {
  MinePage({Key? key}) : super(key: key, title: '');

  final MineLogic logic = Get.put(MineLogic());
  final MineState state = Get.find<MineLogic>().state;
  final List<_MineFuncItem> _funcItems = const [
    _MineFuncItem(title: '个人主页', icon: 'mine_func_1'),
    _MineFuncItem(title: '待办', icon: 'mine_func_2'),
    _MineFuncItem(title: '个人信息', icon: 'mine_func_3'),
    _MineFuncItem(title: '账户管理', icon: 'mine_func_4'),
    _MineFuncItem(title: '活动中心', icon: 'mine_func_5'),
    _MineFuncItem(title: '我的足迹', icon: 'mine_func_6'),
    _MineFuncItem(title: '我的收藏', icon: 'mine_func_7'),
    _MineFuncItem(title: '财富规划', icon: 'mine_func_8'),
    _MineFuncItem(title: '代扣管理', icon: 'mine_func_9'),
    _MineFuncItem(title: '我的支付', icon: 'mine_func_10'),
    _MineFuncItem(title: '资信证明', icon: 'mine_func_11'),
    _MineFuncItem(title: '隐私管理', icon: 'mine_func_12'),
  ];

  @override
  bool get isChangeNav => true;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          const BaseText(
            text: '退出',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF181818),
            ),
          ).withOnTap(onTap: () {
            //退出登录
          })
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Image(
          image: 'nav_right_kf'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_set'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_msg'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 650, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_mine_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                left: position1.getX(80),
                top: position1.getY(245),
                child: Image(
                  image: 'mine_user_icon'.png,
                  width: position1.getWidth(150),
                  fit: BoxFit.fitWidth,
                )
            ),
            Positioned(
                left: position1.getX(270),
                top: position1.getY(240),
                child: BaseText(
                  text: AppConfig.config.abcLogic.realName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Color(0xFF181818),
                  ),
                )
            ),
            Positioned(
                left: position1.getX(270),
                top: position1.getY(330),
                child:const BaseText(
                  text: '开启财富管理之旅',
                  fontSize: 13,
                  color: Color(0xFF878787),
                )
            ),
            // 借记卡积分
            Positioned(
                left: position1.getX(80),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 16,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
            Positioned(
                left: position1.getX(290),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 16,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
            Positioned(
                left: position1.getX(515),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 16,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      BaseText(
                        text: '张',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 16,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
          ],
        ),
        Stack(
          children: [
            Image(image: 'bg_mine_2'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 13.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.w),
                      child: SizedBox(
                        height: 76.w,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            logic.updateFuncScrollProgress(notification.metrics);
                            return false;
                          },
                          child: PageView.builder(
                            controller: logic.funcPageController,
                            padEnds: false,
                            physics: const PageScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                            itemCount: _funcItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(top: 17.w),
                                child: _MineFuncButton(
                                  item: _funcItems[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => _MineFuncIndicator(
                      progress: logic.funcScrollProgress.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        // Image(image: 'bg_mine_2'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
        // Image(image: 'bg_mine_3'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
      ],
    );
  }
}

class _MineFuncItem {
  const _MineFuncItem({
    required this.title,
    required this.icon,
  });

  final String title;
  final String icon;
}

class _MineFuncButton extends StatelessWidget {
  const _MineFuncButton({
    required this.item,
  });

  final _MineFuncItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 22.w,
          child: Center(
            child: Image(
              image: item.icon.png,
              width: 22.w,
              height: 22.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 8.w),
        BaseText(
          text: item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          fontSize: 13,
          color: const Color(0xFF181818),
        ),
      ],
    );
  }
}

class _MineFuncIndicator extends StatelessWidget {
  const _MineFuncIndicator({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 22.0;
    const thumbWidth = 8.0;

    return Container(
      width: trackWidth.w,
      height: 3.w,
      margin: EdgeInsets.only(top: 3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF0),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Stack(
        children: [
          Positioned(
            left: (trackWidth - thumbWidth).w * progress,
            top: 0,
            child: Container(
              width: thumbWidth.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: const Color(0xFFBFC5CF),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
