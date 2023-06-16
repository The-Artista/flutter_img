import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_img/src/shapes.dart';
import 'package:flutter_svg/svg.dart';

class AssetImagehandeler extends StatelessWidget {
  const AssetImagehandeler(
    this.src, {
    super.key,
    this.height,
    this.width,
    this.shape,
    this.padding,
    this.margin,
    this.border,
    this.colorFilter,
    this.borderRadius,
    this.backgroundColor,
  });

  final String src;
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
    if (_getFileExtension(src) == '.png' ||
        _getFileExtension(src) == '.jpg' ||
        _getFileExtension(src) == '.jpeg') {
      return _buildImage();
    }
    return _buildSvgImage();
  }

  String _getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Widget _buildImage() {
    double? calHeight = 0;
    double? calWidth = 0;
    final image = Image.asset(src);
    final completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          final ratio =
              MediaQuery.of(context).size.width / snapshot.data!.width;
          calWidth = ratio * snapshot.data!.width;
          calHeight = ratio * snapshot.data!.height;
        }
        return ImageShape(
          height: height ?? calHeight,
          width: width ?? calWidth,
          shape: shape,
          border: border,
          padding: padding,
          margin: margin,
          borderRadius: borderRadius,
          colorFilter: colorFilter,
          backgroundColor: backgroundColor,
          child: Image.asset(
            src,
            height: height ?? calHeight,
            width: width ?? calWidth,
          ),
        );
      },
    );
  }

  Widget _buildSvgImage() {
    if (_getFileExtension(src) == '.svg') {
      return ImageShape(
        shape: shape,
        border: border,
        backgroundColor: backgroundColor,
        padding: padding,
        margin: margin,
        colorFilter: colorFilter,
        borderRadius: borderRadius,
        child: SvgPicture.asset(src),
      );
    }
    return ImageShape(
      shape: shape,
      border: border,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      colorFilter: colorFilter,
      borderRadius: borderRadius,
      child: SvgPicture.string(src),
    );
  }
}
