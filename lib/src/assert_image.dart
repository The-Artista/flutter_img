import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_img/src/shapes.dart';
import 'package:flutter_svg/svg.dart';

/// [AssetImageHandler] will handel asset image
class AssetImageHandler extends StatelessWidget {
  /// for [AssetImageHandler], [AssetImageHandler.src] is required
  const AssetImageHandler(
    this.src, {
    super.key,
    this.package,
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

  /// `src` is the asset image source for [AssetImageHandler].
  final String src;

  /// `package` is the name of the package where the image is located.
  /// It's only used for asset images
  final String? package;

  /// `height` explicitly set image height. you can pass a
  /// height value or it will adjust the height based on image
  /// height and screen height
  final double? height;

  /// `width` explicitly set image width.
  /// you can pass a height value or it will adjust the width
  /// based on image width and screen width
  final double? width;

  /// The shape parameter can be used to change the shape of the image.
  final BoxShape? shape;

  /// backgroundColor will set the background color of the image
  final Color? backgroundColor;

  /// The border parameter can be used to add the shape of the image.
  final BoxBorder? border;

  /// the padding of the image
  final EdgeInsetsGeometry? padding;

  /// the margin of the image
  final EdgeInsetsGeometry? margin;

  /// using borderRadius You can add a border to the image
  final BorderRadiusGeometry? borderRadius;

  /// The colorFilter allow you to set a color filter over the image
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
            package: package,
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
        child: SvgPicture.asset(
          src,
          package: package,
        ),
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
