import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NetImageWidget extends StatefulWidget {
  const NetImageWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.fill,
    this.width = double.infinity,
    this.height = double.infinity,
    this.radius = 0,
  });

  final String url;
  final BoxFit fit;
  final double width;
  final double height;
  final double radius;

  @override
  State<NetImageWidget> createState() => _NetImageWidgetState();
}

class _NetImageWidgetState extends State<NetImageWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      child: CachedNetworkImage(
        width: widget.width,
        height: widget.height,
        imageUrl: widget.url,
        fit: widget.fit,
        placeholder: (_, __) {
          return Container(
            alignment: Alignment.center,
            width: 45.h,
            height: 45.h,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.all(Radius.circular(4.w))),
            ),
          );
        },
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.all(Radius.circular(4.w))),
        ),
      ),
    );
  }
}
