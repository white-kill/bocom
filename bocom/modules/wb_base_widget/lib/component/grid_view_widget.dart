import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///竖向 一行固定个数
typedef WidgetBuilder = Widget Function(BuildContext context, int index);

class VerticalGridView extends StatefulWidget {
  final WidgetBuilder widgetBuilder;
  final int itemCount ;
  final int crossCount;
  final double spacing;
  final double crossSpacing;
  final double mainHeight;
  final EdgeInsetsGeometry? padding;
  const VerticalGridView({super.key,
    required this.widgetBuilder,
    required this.itemCount,
    this.crossCount = 4,
    this.spacing = 10,
    this.crossSpacing = 10,
    this.mainHeight = 80,
    this.padding =EdgeInsets.zero,
  });

  @override
  State<VerticalGridView> createState() => _VerticalGridViewState();
}

class _VerticalGridViewState extends State<VerticalGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: widget.itemCount,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: widget.padding,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:   SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossCount,
          mainAxisSpacing: widget.spacing,
          crossAxisSpacing: widget.crossSpacing,
          mainAxisExtent: widget.mainHeight.w,
        ),
        itemBuilder: widget.widgetBuilder);
  }
}
