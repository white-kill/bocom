import 'package:flutter/cupertino.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:flutter/material.dart';

class VisibilityDuration extends StatefulWidget {
  final Widget child;
  final String keyId;
  final Function(
    String keyId,
  )? onVisibleForDuration;

  const VisibilityDuration({
    Key? key,
    required this.child,
    required this.keyId,
    this.onVisibleForDuration,
  }) : super(key: key);

  @override
  _VisibilityDurationState createState() => _VisibilityDurationState();
}

class _VisibilityDurationState extends State<VisibilityDuration> {
  DateTime? _visibleStartTime;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.keyId),
      onVisibilityChanged: (info) {
        // widget.onVisibleForDuration
        //     ?.call(widget.keyId);
        final isCurrentlyVisible =
            info.visibleFraction > 0.5; // 可见比例 > 50% 认为可见
        if (isCurrentlyVisible && !_isVisible) {
          _visibleStartTime = DateTime.now();
          _isVisible = true;
        } else if (!isCurrentlyVisible && _isVisible) {
          // 刚变为不可见
          _isVisible = false;
          if (_visibleStartTime != null) {
              widget.onVisibleForDuration
                  ?.call(widget.keyId);
          }
          _visibleStartTime = null;
        }
      },
      child: widget.child,
    );
  }
}

// return VisibilityDuration(
// keyId: widget.skuId,
// data: widget.browseQoList?.toJson(),
// child: itemWidget,
// onVisibleForDuration: (keyId, duration,backData) =>
// VisibilityManage.onVisibleForDuration(
// keyId,
// duration,
// data: backData
// ),
// );