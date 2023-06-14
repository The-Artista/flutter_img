import 'package:flutter/material.dart';

class ImageShape extends StatelessWidget {

  const ImageShape({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.shape,
    this.border,
    this.margin,
    this.borderRadius,
    this.padding,
    this.colorFilter,
    this.backgroundColor = Colors.transparent,
  });
  final Widget child;
  final double? height;
  final double? width;
  final BoxShape? shape;
  final Color? backgroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    if (shape == BoxShape.circle) {
      return Container(
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          border: border,
          shape: BoxShape.circle,
          borderRadius: borderRadius,
        ),
        child: CircleAvatar(
          radius: 100,
          backgroundColor: backgroundColor,
          child: ClipOval(
            child: AspectRatio(
              aspectRatio: 1,
              child: colorFilter != null
                  ? ColorFiltered(
                      colorFilter: colorFilter!,
                      child: child,
                    )
                  : child,
            ),
          ),
        ),
      );
    }
    return Center(
      child: Container(
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: colorFilter != null
            ? ColorFiltered(
                colorFilter: colorFilter!,
                child: child,
              )
            : child,
      ),
    );
  }
}
