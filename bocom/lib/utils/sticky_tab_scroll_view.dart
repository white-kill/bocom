import 'package:bocom/utils/screen_util.dart';
import 'package:bocom/utils/sticky_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Tab项配置
class TabItem {
  final String title;
  final Widget content;
  
  const TabItem({
    required this.title,
    required this.content,
  });
}

/// Tab样式配置
class TabStyle {
  final double fontSize;
  final String? fontFamily;
  final Color selectedColor;
  final Color unselectedColor;
  final FontWeight selectedFontWeight;
  final FontWeight unselectedFontWeight;
  final Color selectedIndicatorColor;
  final double indicatorHeight;
  final double indicatorWidth;
  final double tabHeight;
  final EdgeInsets tabPadding;
  final EdgeInsets tabMargin;
  final EdgeInsets scrollPadding;
  final Color backgroundColor;
  final double tabTextIndicatorSpacing; // 文字和指示器之间的间距
  
  const TabStyle({
    this.fontSize = 16,
    this.fontFamily,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.grey,
    this.selectedFontWeight = FontWeight.w700,
    this.unselectedFontWeight = FontWeight.w500,
    this.selectedIndicatorColor = const Color(0xFFF1501B),
    this.indicatorHeight = 4,
    this.indicatorWidth = 30,
    this.tabHeight = 40,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
    this.tabMargin = const EdgeInsets.only(right: 8),
    this.scrollPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.backgroundColor = Colors.white,
    this.tabTextIndicatorSpacing = 4, // 默认间距为4
  });
}

/// 粘性TabBar滚动视图控制器
class StickyTabScrollViewController extends GetxController {
  final RxInt _selectedTabIndex = 0.obs;
  final RxBool _isScrollingToTab = false.obs;
  
  int get selectedTabIndex => _selectedTabIndex.value;
  bool get isScrollingToTab => _isScrollingToTab.value;
  
  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
    update();
  }
  
  void setScrollingToTab(bool isScrolling) {
    _isScrollingToTab.value = isScrolling;
  }
}

/// 粘性TabBar滚动视图组件
class StickyTabScrollView extends StatefulWidget {
  final List<TabItem> tabs;
  final Widget? header;
  final double headerHeight;
  final double stickyOffset;
  final TabStyle tabStyle;
  final StickyTabScrollViewController? controller;
  final Duration scrollAnimationDuration;
  final Duration tabScrollAnimationDuration;
  final Curve scrollAnimationCurve;
  final Duration cacheDelay; // 缓存延迟时间
  
  const StickyTabScrollView({
    Key? key,
    required this.tabs,
    this.header,
    this.headerHeight = 100,
    this.stickyOffset = 0,
    this.tabStyle = const TabStyle(),
    this.controller,
    this.scrollAnimationDuration = const Duration(milliseconds: 500),
    this.tabScrollAnimationDuration = const Duration(milliseconds: 300),
    this.scrollAnimationCurve = Curves.easeInOut,
    this.cacheDelay = const Duration(seconds: 1), // 默认延迟1秒缓存
  }) : super(key: key);

  @override
  State<StickyTabScrollView> createState() => _StickyTabScrollViewState();
}

class _StickyTabScrollViewState extends State<StickyTabScrollView> {
  late final ScrollController _scrollController;
  late final StickyController _stickyController;
  late final List<GlobalKey> _sectionKeys;
  late final StickyTabScrollViewController _logic;
  
  // 缓存Tab位置信息（实例变量，避免冲突）
  final Map<int, double> _cachedTabPositions = {};
  final Map<int, double> _cachedTabWidths = {};
  final Map<int, double> _cachedSectionPositions = {};
  bool _tabPositionsCached = false;
  bool _sectionPositionsCached = false;

  @override
  void initState() {
    super.initState();
    
    // 创建控制器
    _scrollController = ScrollController();
    _stickyController = StickyController();
    _sectionKeys = List.generate(widget.tabs.length, (index) => GlobalKey());
    _logic = widget.controller ?? Get.put(StickyTabScrollViewController());
    
    // 监听滚动事件，实现TabBar联动选中
    _scrollController.addListener(() {
      _stickyController.updateScrollOffset(_scrollController.offset);
      _updateSelectedTabOnScroll(_scrollController.offset);
    });
    
    // 在页面加载完成后延迟缓存所有位置信息（确保渲染完成）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.cacheDelay, () {
        _cacheSectionPositions();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要内容
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              _stickyController.updateScrollOffset(_scrollController.offset);
              _updateSelectedTabOnScroll(_scrollController.offset);
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Header
                if (widget.header != null) 
                  widget.header!
                else
                  SizedBox(height: widget.headerHeight),
                
                // TabBar占位空间
                SizedBox(height: widget.tabStyle.tabHeight.w),
                
                // 所有内容
                ...List.generate(widget.tabs.length, (index) {
                  return Container(
                    key: _sectionKeys[index], // 使用GlobalKey进行精确定位
                    child: widget.tabs[index].content,
                  );
                }),
              ],
            ),
          ),
        ),
        
        // 悬停的TabBar
        StickyWidget.withController(
          controller: _stickyController,
          initialOffset: widget.headerHeight, // TabBar初始位置
          stickyOffset: widget.stickyOffset, // 悬停时距离顶部的距离
          child: _buildTabBar(),
        ),
      ],
    );
  }

  /// 构建TabBar
  Widget _buildTabBar() {
    // 创建TabBar的滚动控制器
    final ScrollController tabScrollController = ScrollController();
    
    return Container(
      height: widget.tabStyle.tabHeight.w,
      alignment: Alignment.centerLeft,
      color: widget.tabStyle.backgroundColor,
      child: GetBuilder<StickyTabScrollViewController>(
        builder: (logic) {
          // 当选中的Tab改变时，滚动到可见位置
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollTabToVisible(logic.selectedTabIndex, tabScrollController);
          });
          
          return ListView.builder(
            controller: tabScrollController,
            scrollDirection: Axis.horizontal,
            padding: widget.tabStyle.scrollPadding,
            itemCount: widget.tabs.length,
            itemBuilder: (context, index) {
              final isSelected = logic.selectedTabIndex == index;
              return GestureDetector(
                onTap: () => _onTabTap(index),
                child: Container(
                  key: ValueKey('tab_$index'), // 为每个Tab添加key用于定位
                  padding: widget.tabStyle.tabPadding,
                  margin: widget.tabStyle.tabMargin,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.tabs[index].title,
                        style: TextStyle(
                          fontSize: widget.tabStyle.fontSize.sp,
                          fontFamily: widget.tabStyle.fontFamily,
                          color: isSelected 
                              ? widget.tabStyle.selectedColor 
                              : widget.tabStyle.unselectedColor,
                          fontWeight: isSelected 
                              ? widget.tabStyle.selectedFontWeight 
                              : widget.tabStyle.unselectedFontWeight,
                        ),
                      ),
                      SizedBox(height: widget.tabStyle.tabTextIndicatorSpacing.h),
                      // 选中状态的下划线
                      Container(
                        height: widget.tabStyle.indicatorHeight.h,
                        width: isSelected ? widget.tabStyle.indicatorWidth.w : 0,
                        decoration: BoxDecoration(
                          color: widget.tabStyle.selectedIndicatorColor,
                          borderRadius: BorderRadius.circular(5.h),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Tab点击事件
  void _onTabTap(int index) {
    _logic.setSelectedTabIndex(index);
    _logic.setScrollingToTab(true); // 设置正在滚动到Tab的标志
    _scrollToSection(index);
    
    // 滚动完成后重置标志
    Future.delayed(Duration(milliseconds: widget.scrollAnimationDuration.inMilliseconds + 100), () {
      _logic.setScrollingToTab(false);
    });
  }

  /// 滚动到指定区域 - 使用缓存的相对位置信息
  void _scrollToSection(int index) {
    if (index >= _sectionKeys.length) return;
    
    // 使用缓存的相对位置信息
    final cachedPosition = _cachedSectionPositions[index];
    if (cachedPosition != null) {
      // 计算目标滚动位置：缓存的相对位置 - TabBar高度（因为TabBar会悬停）
      final targetOffset = cachedPosition - widget.tabStyle.tabHeight.w;
      
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: widget.scrollAnimationDuration,
        curve: widget.scrollAnimationCurve,
      );
    }
  }

  /// 根据滚动位置更新选中的Tab（使用缓存优化）
  void _updateSelectedTabOnScroll(double scrollOffset) {
    // 防止在点击Tab时触发滚动联动
    if (_logic.isScrollingToTab) return;

    // 如果缓存还没完成，直接返回
    if (!_sectionPositionsCached) return;

    int newSelectedIndex = 0;
    double minDistance = double.infinity;

    // TabBar悬停时的高度偏移
    double tabBarOffset = widget.tabStyle.tabHeight.w;

    for (int i = 0; i < _sectionKeys.length; i++) {
      double? cachedPosition = _cachedSectionPositions[i];

      if (cachedPosition != null) {
        // 计算section相对于当前滚动位置的距离
        // cachedPosition是section在内容中的位置，scrollOffset + tabBarOffset是当前视口顶部在内容中的位置
        final distance = (cachedPosition - (scrollOffset + tabBarOffset)).abs();

        if (distance < minDistance) {
          minDistance = distance;
          newSelectedIndex = i;
        }
      }
    }

    if (newSelectedIndex != _logic.selectedTabIndex) {
      _logic.setSelectedTabIndex(newSelectedIndex);
    }
  }

  /// 缓存Tab位置信息（懒加载）
  void _cacheTabPositions() {
    if (_tabPositionsCached) return;
    
    _cachedTabPositions.clear();
    _cachedTabWidths.clear();
    
    double currentPosition = widget.tabStyle.scrollPadding.left; // 初始左padding
    
    for (int i = 0; i < widget.tabs.length; i++) {
      double tabWidth = _calculateTabWidth(i);
      _cachedTabPositions[i] = currentPosition;
      _cachedTabWidths[i] = tabWidth;
      currentPosition += tabWidth;
    }
    
    _tabPositionsCached = true;
  }
  
  /// 缓存Section位置信息（相对于ListView内容的位置）
  void _cacheSectionPositions() {
    _cachedSectionPositions.clear();
    
    // 计算相对于ListView内容的位置
    double currentOffset = 0;
    
    // Header高度
    currentOffset += widget.headerHeight;
    
    // TabBar占位空间高度
    currentOffset += widget.tabStyle.tabHeight.w;
    
    // 遍历每个section，累积计算其在ListView内容中的位置
    for (int i = 0; i < _sectionKeys.length; i++) {
      final RenderBox? renderBox = _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // 存储section在ListView内容中的相对位置
        _cachedSectionPositions[i] = currentOffset;
        
        // 累加当前section的高度，为下一个section做准备
        currentOffset += renderBox.size.height;
      }
    }
    _sectionPositionsCached = true;
  }

  /// 滚动Tab到可见位置（模拟系统TabBar效果）
  void _scrollTabToVisible(int selectedIndex, ScrollController tabScrollController) {
    if (!tabScrollController.hasClients) return;
    
    // 确保Tab位置已缓存
    _cacheTabPositions();
    
    double? selectedTabPosition = _cachedTabPositions[selectedIndex];
    double? selectedTabWidth = _cachedTabWidths[selectedIndex];
    
    if (selectedTabPosition == null || selectedTabWidth == null) return;
    
    // 获取TabBar的可见宽度
    double visibleWidth = screenWidth - widget.tabStyle.scrollPadding.horizontal; // 减去左右padding
    
    // 计算目标滚动位置（让选中的Tab尽量居中）
    double targetOffset = selectedTabPosition - (visibleWidth / 2) + (selectedTabWidth / 2);
    
    // 限制滚动范围
    targetOffset = targetOffset.clamp(0.0, tabScrollController.position.maxScrollExtent);
    
    // 平滑滚动到目标位置
    tabScrollController.animateTo(
      targetOffset,
      duration: widget.tabScrollAnimationDuration,
      curve: widget.scrollAnimationCurve,
    );
  }

  /// 精确计算Tab的宽度
  double _calculateTabWidth(int index) {
    if (index >= widget.tabs.length) return 0;
    
    // 根据文字长度精确计算宽度
    String title = widget.tabs[index].title;
    double textWidth = title.length * widget.tabStyle.fontSize.sp * 0.7; // 更精确的估算
    double padding = widget.tabStyle.tabPadding.horizontal; // 左右padding
    double margin = widget.tabStyle.tabMargin.horizontal; // 右边距
    
    return textWidth + padding + margin;
  }
}
