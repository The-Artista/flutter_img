
import 'package:flutter/material.dart';
import 'package:flutter_img/src/assert_image.dart';
import 'package:flutter_img/src/network_image.dart';

///
/// A widget that renders your images
///
/// `src` is the one and only positional parameter here,
/// and its required it will take the asset link, HTTP image link,
/// or SVG code as a string. as you know it takes a string,
/// so for SVG code make sure there is no new line.
///
class Img extends StatelessWidget {
  ///
  /// A widget that renders your images
  ///
  /// `src` is the one and only positional parameter here,
  /// and its required it will take the asset link, HTTP image link,
  /// or SVG code as a string. as you know it takes a string,
  /// so for SVG code make sure there is no new line.
  ///
  const Img(
    this.src, {
    super.key,
    this.height,
    this.blurHash,
    this.placeholder,
    this.width,
    this.shape,
    this.border,
    this.borderRadius,
    this.margin,
    this.padding,
    this.colorFilter,
    this.bgColor,
    this.fit,
  });

  /// `src` is the image source for [Img].
  /// `src` string can be a asset or network.
  final String src;

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

  /// The border parameter can be used to add the shape of the image.
  final BoxBorder? border;

  /// using borderRadius You can add a border to the image
  final BorderRadiusGeometry? borderRadius;

  /// the margin of the image
  final EdgeInsetsGeometry? margin;

  /// the padding of the image
  final EdgeInsetsGeometry? padding;

  /// bgColor will set the background color of the image
  final Color? bgColor;

  /// The colorFilter allow you to set a color filter over the image
  final ColorFilter? colorFilter;

  /// box fit of the image
  final BoxFit? fit;

  /// The placeholder parameter allows you to
  /// provide any widget as a placeholder before the network image
  /// is fully loaded. this parameter only works with png,
  /// jpg/jpeg network images. asset images or SVG images will not be affected
  final Widget? placeholder;

  /// The blurHash parameter also allows you to load blurhash
  /// images before the network image is fully loaded.
  /// this parameter only works with png, jpg/jpeg network images.
  /// asset images or SVG images will not be affected.
  /// By default, if you don't provide placeholder blursh will apply.
  /// and the default value is L5H2EC=PM+yV0g-mq.wG9c010J}I
  final String? blurHash;


  @override
  Widget build(BuildContext context) {
    if (_getImageType() == 'network') {
      return NetworkImagehandeler(src);
    } else {
      return AssetImagehandeler(src);
    }
  }

  String _getImageType() {
    final httpRegX = RegExp(
      r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])',
    );
    if (httpRegX.hasMatch(src)) {
      return 'network';
    } else {
      return 'asset';
    }
  }
}
