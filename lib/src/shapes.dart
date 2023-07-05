import 'package:flutter/material.dart';

/// [ImageShape] will handel image shape, border, and colors
class ImageShape extends StatelessWidget {
  /// [ImageShape.child] is only required property here
  const ImageShape({
    required this.child,
    super.key,
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

  /// [ImageShape.child] will take a image widget
  final Widget child;

  /// height of image
  final double? height;

  /// width of image
  final double? width;

  /// [ImageShape.shape] will take a [BoxShape]. for now flutter_img support
  /// [BoxShape.circle] and [BoxShape.rectangle]
  final BoxShape? shape;

  /// image background [Color]

  final Color? backgroundColor;

  /// border will take [BoxBorder] for decorate the image
  final BoxBorder? border;

  /// padding will apply [EdgeInsetsGeometry] for the image
  /// if [ImageShape.backgroundColor] is not null it will
  /// not effect the background
  final EdgeInsetsGeometry? padding;

  /// margin will apply [EdgeInsetsGeometry] for the image
  /// if [ImageShape.backgroundColor] it will actually apply to
  /// [ImageShape.backgroundColor]
  final EdgeInsetsGeometry? margin;

  /// borderRadius will apply [BorderRadiusGeometry] for the image
  final BorderRadiusGeometry? borderRadius;

  /// colorFilter will apply [ColorFilter] for the image
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
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: colorFilter != null
              ? ColorFiltered(
            colorFilter: colorFilter!,
            child: child,
          )
              : child,
        ),
      ),
    );
  }
}
