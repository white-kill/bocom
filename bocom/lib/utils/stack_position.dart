import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StackPosition {
  /// 设计稿宽度
  final double designWidth;
  
  /// 设计稿高度
  final double designHeight;
  
  /// 真机宽度
  final double deviceWidth;

  StackPosition({
    required this.designWidth,
    required this.designHeight,
    required this.deviceWidth,
  });

  /// 设计稿的宽高比
  double get designAspectRatio => designWidth / designHeight;

  /// 根据真机宽度计算真机上的显示高度（保持设计稿的宽高比）
  double get deviceHeight => deviceWidth / designAspectRatio;

  /// 计算缩放比例（以宽度为基准）
  double get scale => deviceWidth / designWidth;

  /// 根据设计稿中的X坐标计算真机上的X坐标
  double getX(double designX) {
    return designX * scale;
  }

  /// 根据设计稿中的Y坐标计算真机上的Y坐标
  double getY(double designY) {
    return designY * scale;
  }

  /// 根据设计稿中的宽度计算真机上的宽度
  double getWidth(double designWidth) {
    return designWidth * scale;
  }

  /// 根据设计稿中的高度计算真机上的高度
  double getHeight(double designHeight) {
    return designHeight * scale;
  }

  /// 根据设计稿中的位置和尺寸计算真机上的位置和尺寸
  Map<String, double> getPositionAndSize({
    required double designX,
    required double designY,
    required double designWidth,
    required double designHeight,
  }) {
    return {
      'x': getX(designX),
      'y': getY(designY),
      'width': getWidth(designWidth),
      'height': getHeight(designHeight),
    };
  }

  /// 根据设计稿中的百分比位置计算真机上的绝对位置（相对于计算出的高度）
  double getXFromPercent(double percentX) {
    return (percentX / 100) * deviceWidth;
  }

  /// 根据设计稿中的百分比位置计算真机上的绝对位置（相对于计算出的高度）
  double getYFromPercent(double percentY) {
    return (percentY / 100) * deviceHeight;
  }

  /// 根据设计稿中的百分比位置和尺寸计算真机上的位置和尺寸
  Map<String, double> getPositionAndSizeFromPercent({
    required double percentX,
    required double percentY,
    required double percentWidth,
    required double percentHeight,
  }) {
    return {
      'x': getXFromPercent(percentX),
      'y': getYFromPercent(percentY),
      'width': (percentWidth / 100) * deviceWidth,
      'height': (percentHeight / 100) * deviceHeight,
    };
  }

  /// 获取适配后的尺寸信息
  Map<String, double> getAdaptedSize() {
    return {
      'width': deviceWidth,
      'height': deviceHeight,
      'scale': scale,
      'aspectRatio': designAspectRatio,
    };
  }

  /// 创建默认实例
  factory StackPosition.defaultInstance() {
    return StackPosition(
      designWidth: 375, // 常见设计稿宽度
      designHeight: 812, // 常见设计稿高度
      deviceWidth: 375, // 需要从MediaQuery获取
    );
  }
}


class StackPositionWidget {
  final StackPosition stackPosition;
  final double designX;
  final double designY;
  final double designWidth;
  final double designHeight;

  StackPositionWidget({
    required this.stackPosition,
    required this.designX,
    required this.designY,
    required this.designWidth,
    required this.designHeight,
  });

  /// 简化的构建方法
  Widget build({Color? bgColor = Colors.transparent, Function()? onTap}) {
    return Positioned(
      left: stackPosition.getX(designX),
      top: stackPosition.getY(designY),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: stackPosition.getWidth(designWidth),
          height: stackPosition.getHeight(designHeight),
          color: bgColor,
        ),
      ),
    );
  }

  /// 更简单的工厂方法
  factory StackPositionWidget.fromDesign({
    required StackPosition sp,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    return StackPositionWidget(
      stackPosition: sp,
      designX: x,
      designY: y,
      designWidth: width,
      designHeight: height,
    );
  }
}

/// 网格定位组件 - 用于在Stack中定位网格布局
class StackPositionGridWidget {
  final StackPosition stackPosition;
  final double designX;
  final double designY;
  final double bottomMargin;
  final double rightMargin;
  final int crossCount;
  final int itemCount;
  final Widget Function(BuildContext context, int index)? childBuilder;
  final Function(int index)? onItemTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color itemBackgroundColor;

  /// 自动计算设计稿宽度（考虑右边距）
  double get designWidth {
    // 计算实际的结束X坐标：设计稿总宽度 - 距离右边的距离
    double actualEndX = stackPosition.designWidth - rightMargin;
    return actualEndX - designX;
  }
  
  /// 自动计算网格区域高度
  double get designHeight {
    // 计算实际的结束Y坐标：设计稿总高度 - 距离底部的距离
    double actualEndY = stackPosition.designHeight - bottomMargin;
    return actualEndY - designY;
  }

  StackPositionGridWidget({
    required this.stackPosition,
    required this.designX,
    required this.designY,
    this.bottomMargin = 0,
    this.rightMargin = 0,
    this.childBuilder,
    this.crossCount = 4,
    this.itemCount = 1,
    this.onItemTap,
    this.padding,
    this.backgroundColor,
    this.itemBackgroundColor = Colors.transparent,
  });

  /// 自动计算每个item的高度
  double get _itemHeight {
    // 计算行数
    int rowCount = (itemCount / crossCount).ceil();
    
    // 平均分配高度，无间距
    return designHeight / rowCount;
  }

  /// 构建定位的网格布局组件
  Widget build() {
    return Positioned(
      left: stackPosition.getX(designX),
      top: stackPosition.getY(designY),
      child: Container(
        width: stackPosition.getX(designWidth),
        height: stackPosition.getY(designHeight),
        color: backgroundColor,
        child: GridView.builder(
          itemCount: itemCount,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: padding ?? EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            mainAxisExtent: stackPosition.getHeight(_itemHeight),
          ),
          itemBuilder: (context, index) {
            // 自动计算item的宽高
            double itemWidth = stackPosition.getWidth(designWidth) / crossCount;
            double itemHeight = stackPosition.getHeight(_itemHeight);
            
            Widget itemContent = Container(
              width: itemWidth,
              height: itemHeight,
              color: itemBackgroundColor,
              child: childBuilder?.call(context, index),
            );
            
            if (onItemTap != null) {
              return InkWell(
                onTap: () => onItemTap!(index),
                child: itemContent,
              );
            }
            return itemContent;
          },
        ),
      ),
    );
  }

  /// 简化的工厂方法 - 基于4x4网格
  factory StackPositionGridWidget.grid4x4({
    required StackPosition stackPosition,
    required double x,
    required double y,
    double bottomMargin = 0,
    double rightMargin = 0,
    Widget Function(BuildContext context, int index)? childBuilder,
    Function(int index)? onItemTap,
    int itemCount = 16,
    Color? backgroundColor,
    Color itemBackgroundColor = Colors.transparent,
  }) {
    return StackPositionGridWidget(
      stackPosition: stackPosition,
      designX: x,
      designY: y,
      bottomMargin: bottomMargin,
      rightMargin: rightMargin,
      childBuilder: childBuilder,
      crossCount: 4,
      itemCount: itemCount,
      onItemTap: onItemTap,
      backgroundColor: backgroundColor,
      itemBackgroundColor: itemBackgroundColor,
    );
  }

  /// 简化的工厂方法 - 基于5x5网格
  factory StackPositionGridWidget.grid5x5({
    required StackPosition stackPosition,
    required double x,
    required double y,
    double bottomMargin = 0,
    double rightMargin = 0,
    Widget Function(BuildContext context, int index)? childBuilder,
    Function(int index)? onItemTap,
    int itemCount = 25,
    Color? backgroundColor,
    Color itemBackgroundColor = Colors.transparent,
  }) {
    return StackPositionGridWidget(
      stackPosition: stackPosition,
      designX: x,
      designY: y,
      bottomMargin: bottomMargin,
      rightMargin: rightMargin,
      childBuilder: childBuilder,
      crossCount: 5,
      itemCount: itemCount,
      onItemTap: onItemTap,
      backgroundColor: backgroundColor,
      itemBackgroundColor: itemBackgroundColor,
    );
  }

  /// 简化的工厂方法 - 自定义网格
  factory StackPositionGridWidget.custom({
    required StackPosition stackPosition,
    required double x,
    required double y,
    double bottomMargin = 0,
    double rightMargin = 0,
    Widget Function(BuildContext context, int index)? childBuilder,
    required int crossCount,
    required int itemCount,
    Function(int index)? onItemTap,
    Color? backgroundColor,
    Color itemBackgroundColor = Colors.transparent,
    EdgeInsetsGeometry? padding,
  }) {
    return StackPositionGridWidget(
      stackPosition: stackPosition,
      designX: x,
      designY: y,
      bottomMargin: bottomMargin,
      rightMargin: rightMargin,
      childBuilder: childBuilder,
      crossCount: crossCount,
      itemCount: itemCount,
      onItemTap: onItemTap,
      backgroundColor: backgroundColor,
      itemBackgroundColor: itemBackgroundColor,
      padding: padding,
    );
  }
}
