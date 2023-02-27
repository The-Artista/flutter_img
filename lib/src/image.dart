import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_img/src/svg_decoration.dart';
import 'package:flutter_img/src/svg_provider.dart';

class Img extends StatelessWidget {
  final String src;
  final double? height;
  final double? width;
  final BoxShape? shape;
  final BoxBorder? border;

  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? bgColor;
  final ColorFilter? colorFilter;
  final BoxFit? fit;
  final Widget? placeholder;
  final String? blurHash;
  final Widget? child;

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
        this.child = const Text(''),
      });

  @override
  Widget build(BuildContext context) {
    final svgRegX = RegExp(r'<\s*svg[^>]*>(.*?)<\s*/\s*svg>');
    if (svgRegX.hasMatch(src)) {
      return Container(
        height: height ?? MediaQuery.of(context).size.height,
        width: width ?? MediaQuery.of(context).size.width,
        margin: margin,
        padding: padding,
        decoration: SvgDecoration.string(src),
        // need to marge with ImageProvider
        child: child,
      );
    } else if (getImageType(src) == "asset") {
      final svgExtRegX = RegExp(r'\.(svg)(?:\?.*|)$');
      if (svgExtRegX.hasMatch(src)) {
        return Container(
          height: height,
          width: width ?? MediaQuery.of(context).size.width,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            shape: shape ?? BoxShape.rectangle,
            borderRadius: borderRadius,
            border: border,
            color: bgColor,
            image: DecorationImage(
              fit: fit,
              colorFilter: colorFilter,
              image: getImageProvider(src),
            ),
          ),
          // need to marge with ImageProvider
          child: child,
        );
      } else {
        double? calHeight = 0;
        double? calWidth = 0;
        Image image = Image.asset(src);
        Completer<ui.Image> completer = Completer<ui.Image>();
        image.image
            .resolve(const ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }));

        return FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            if (snapshot.hasData) {
              final ratio =
                  MediaQuery.of(context).size.width / snapshot.data!.width;
              calWidth = ratio * snapshot.data!.width;
              calHeight = ratio * snapshot.data!.height;
            }
            return Container(
              height: height ?? calHeight,
              width: width ?? calWidth,
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                shape: shape ?? BoxShape.rectangle,
                borderRadius: borderRadius,
                border: border,
                color: bgColor,
                image: DecorationImage(
                  fit: fit,
                  colorFilter: colorFilter,
                  image: getImageProvider(src),
                ),
              ),
              child: child,
            );
          },
        );
      }
    } else {
      final svgExtRegX = RegExp(r'\.(svg)(?:\?.*|)$');
      if(!svgExtRegX.hasMatch(src)){
        double? calHeight = 0;
        double? calWidth = 0;
        Image image = Image.network(src);
        Completer<ui.Image> completer = Completer<ui.Image>();
        image.image
            .resolve(const ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }));
        return FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            if (snapshot.hasData) {
              final ratio =
                  MediaQuery.of(context).size.width / snapshot.data!.width;
              calWidth = ratio * snapshot.data!.width;
              calHeight = ratio * snapshot.data!.height;
            }
            return CachedNetworkImage(
              imageUrl: src,
              imageBuilder: (context, imageProvider) {
                return Container(
                  height: height ?? calHeight,
                  width: width ?? calWidth,
                  margin: margin,
                  padding: padding,
                  decoration: BoxDecoration(
                    shape: shape ?? BoxShape.rectangle,
                    borderRadius: borderRadius,
                    border: border,
                    color: bgColor,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: fit,
                      colorFilter: colorFilter,
                    ),
                  ),
                  // need to marge with ImageProvider
                  child: child,
                );
              },
              height: height ?? calHeight,
              width: width ?? calWidth,
              placeholder: (context, url) {
                return placeholder ??
                    BlurHash(hash: blurHash ?? "L5H2EC=PM+yV0g-mq.wG9c010J}I");
              },
            );
          },
        );
      }
      else{
        return Container(
          height: height,
          width: width ?? MediaQuery.of(context).size.width,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            shape: shape ?? BoxShape.rectangle,
            borderRadius: borderRadius,
            border: border,
            color: bgColor,
            image: DecorationImage(
              image: getImageProvider(src),
              fit: fit,
              colorFilter: colorFilter,
            ),
          ),
          // need to marge with ImageProvider
          child: child,
        );
      }
    }
  }
}

ImageProvider<Object> getImageProvider(String src) {
  final httpRegX = RegExp(
    r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])',
  );
  final svgExtRegX = RegExp(r'\.(svg)(?:\?.*|)$');
  if (httpRegX.hasMatch(src)) {
    if (svgExtRegX.hasMatch(src)) {
      return SvgProvider(
        src,
        source: SvgSource.network,
      );
    } else {
      return NetworkImage(src);
    }
  } else {
    if (svgExtRegX.hasMatch(src)) {
      return SvgProvider(
        src,
      );
    } else {
      return AssetImage(src);
    }
  }
}

ImageProvider<Object> getImage(String src) {
  final httpRegX = RegExp(
    r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])',
  );
  final svgExtRegX = RegExp(r'\.(svg)(?:\?.*|)$');
  if (httpRegX.hasMatch(src)) {
    if (svgExtRegX.hasMatch(src)) {
      return SvgProvider(
        src,
        source: SvgSource.network,
      );
    } else {
      return NetworkImage(src);
    }
  } else {
    if (svgExtRegX.hasMatch(src)) {
      return SvgProvider(
        src,
      );
    } else {
      return AssetImage(src);
    }
  }
}

String getImageType(String src) {
  final httpRegX = RegExp(
    r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])',
  );
  if (httpRegX.hasMatch(src)) {
    return 'network';
  } else {
    return "asset";
  }
}