import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class WbLoadingWidget extends StatefulWidget {
  final ImageProvider image;
  final String loadingText;
  const WbLoadingWidget({super.key, required this.image,required this.loadingText});

  @override
  State<WbLoadingWidget> createState() => _WbLoadingWidgetState();
}

class _WbLoadingWidgetState extends State<WbLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoadingThree();
  }
  Widget _buildLoadingThree() {
    return Center(
      child: Container(
        height: 105.w,
        width: 105.w,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RotationTransition(
            alignment: Alignment.center,
            turns: _controller,
            child: Image(
              image: widget.image,
              height: 45,
              width: 45,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.w),
            child: BaseText(text: widget.loadingText,color: Colors.white,),
          ),
        ]),
      ),
    );
  }
}
