import 'package:flutter/material.dart';

/// 悬停控制器
/// 用于外部传递滚动偏移量到悬停组件
class StickyController extends ChangeNotifier {
  double _scrollOffset = 0.0;
  
  /// 获取当前滚动偏移量
  double get scrollOffset => _scrollOffset;
  
  /// 更新滚动偏移量
  void updateScrollOffset(double offset) {
    if (_scrollOffset != offset) {
      _scrollOffset = offset;
      notifyListeners();
    }
  }
  
  /// 重置滚动偏移量
  void reset() {
    updateScrollOffset(0.0);
  }
}

/// 悬停组件
/// 可以让任何 Widget 在滚动时悬停在指定位置
/// 支持两种使用方式：
/// 1. 传入 StickyController（推荐）
/// 2. 直接传入 scrollOffset 值
class StickyWidget extends StatefulWidget {
  final Widget child; // 要悬停的组件
  final double initialOffset; // 初始位置
  final double stickyOffset; // 悬停时的偏移量（距离顶部的距离）
  
  // 方式一：使用 StickyController（推荐）
  final StickyController? controller;
  
  // 方式二：直接传入 scroll offset 值
  final double? scrollOffset;

  const StickyWidget({
    Key? key,
    required this.child,
    required this.initialOffset,
    required this.stickyOffset,
    this.controller,
    this.scrollOffset,
  }) : assert(
         (controller != null) ^ (scrollOffset != null),
         'Either controller or scrollOffset must be provided, but not both.',
       ),
       super(key: key);

  /// 使用 StickyController 的构造函数
  const StickyWidget.withController({
    Key? key,
    required Widget child,
    required double initialOffset,
    required double stickyOffset,
    required StickyController controller,
  }) : this(
         key: key,
         child: child,
         initialOffset: initialOffset,
         stickyOffset: stickyOffset,
         controller: controller,
       );

  /// 直接使用 scrollOffset 的构造函数
  const StickyWidget.withOffset({
    Key? key,
    required Widget child,
    required double initialOffset,
    required double stickyOffset,
    required double scrollOffset,
  }) : this(
         key: key,
         child: child,
         initialOffset: initialOffset,
         stickyOffset: stickyOffset,
         scrollOffset: scrollOffset,
       );

  @override
  State<StickyWidget> createState() => _StickyWidgetState();
}

class _StickyWidgetState extends State<StickyWidget> {
  // 状态变量
  bool _isSticky = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.addListener(_onScrollOffsetChanged);
    }
    _updateStickyState(); // 初始化状态
  }

  @override
  void didUpdateWidget(StickyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 处理 controller 变化
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScrollOffsetChanged);
      widget.controller?.addListener(_onScrollOffsetChanged);
    }
    
    // 处理 scrollOffset 变化或切换模式
    if (oldWidget.scrollOffset != widget.scrollOffset ||
        oldWidget.controller != widget.controller) {
      _updateStickyState();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScrollOffsetChanged);
    super.dispose();
  }

  /// 滚动偏移量变化回调（仅用于 controller 模式）
  void _onScrollOffsetChanged() {
    if (!mounted) return;
    _updateStickyState();
  }

  /// 获取当前滚动偏移量
  double _getCurrentScrollOffset() {
    if (widget.controller != null) {
      return widget.controller!.scrollOffset;
    } else {
      return widget.scrollOffset ?? 0.0;
    }
  }

  /// 更新悬停状态
  void _updateStickyState() {
    final offset = _getCurrentScrollOffset();
    final triggerPosition = widget.initialOffset;
    
    setState(() {
      if (offset >= triggerPosition && !_isSticky) {
        print("StickyWidget: show - scrollOffset: $offset, triggerPosition: $triggerPosition");
        _isSticky = true;
      } else if (offset < triggerPosition && _isSticky) {
        print("StickyWidget: hidden - scrollOffset: $offset, triggerPosition: $triggerPosition");
        _isSticky = false;
      }
    });
  }

  /// 计算组件的偏移量
  double _calculateOffset() {
    final scrollOffset = _getCurrentScrollOffset();
    
    if (!_isSticky) {
      // 非悬停状态：组件从初始位置开始，随着滚动一起移动
      final offset = widget.initialOffset - scrollOffset + widget.stickyOffset;
      // 确保组件不会超出悬停位置
      return offset > widget.stickyOffset ? offset - widget.stickyOffset : 0;
    } else {
      // 悬停状态：组件固定在悬停位置
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.stickyOffset,
      left: 0,
      right: 0,
      child: Transform.translate(
        offset: Offset(0, _calculateOffset()),
        child: widget.child,
      ),
    );
  }
} 