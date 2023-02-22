import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Image, Picture;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

typedef SvgStringGetter = Future<String?> Function(SvgImageKey key);

enum SvgSource {
  file,
  asset,
  network,
}

class SvgProvider extends ImageProvider<SvgImageKey> {
  final String path;
  final Size? size;

  final Color? color;

  final SvgSource source;

  final double? scale;

  final SvgStringGetter? svgGetter;

  const SvgProvider(
    this.path, {
    this.size,
    this.scale,
    this.color,
    this.source = SvgSource.asset,
    this.svgGetter,
  });

  @override
  Future<SvgImageKey> obtainKey(ImageConfiguration configuration) {
    final Color color = this.color ?? Colors.transparent;
    final double scale = this.scale ?? configuration.devicePixelRatio ?? 1.0;
    final double logicWidth = size?.width ?? configuration.size?.width ?? 100;
    final double logicHeight = size?.height ?? configuration.size?.width ?? 100;

    return SynchronousFuture<SvgImageKey>(
      SvgImageKey(
        path: path,
        scale: scale,
        color: color,
        source: source,
        pixelWidth: (logicWidth * scale).round(),
        pixelHeight: (logicHeight * scale).round(),
        svgGetter: svgGetter,
      ),
    );
  }

  @override
  ImageStreamCompleter load(SvgImageKey key, nil) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  static Future<String> _getSvgString(SvgImageKey key) async {
    if (key.svgGetter != null) {
      final rawSvg = await key.svgGetter!.call(key);
      if (rawSvg != null) {
        return rawSvg;
      }
    }
    switch (key.source) {
      case SvgSource.network:
        return http.read(Uri.parse(key.path));
      case SvgSource.asset:
        return rootBundle.loadString(key.path);
      case SvgSource.file:
        return File(key.path).readAsString();
    }
  }

  static Future<ImageInfo> _loadAsync(SvgImageKey key) async {
    final String rawSvg = await _getSvgString(key);
    final DrawableRoot svgRoot = await svg.fromSvgString(rawSvg, key.path);
    final ui.Picture picture = svgRoot.toPicture(
      size: Size(
        key.pixelWidth.toDouble(),
        key.pixelHeight.toDouble(),
      ),
      clipToViewBox: false,
      colorFilter: ColorFilter.mode(
        getFilterColor(key.color!),
        BlendMode.srcATop,
      ),
    );
    final ui.Image image = await picture.toImage(
      key.pixelWidth,
      key.pixelHeight,
    );

    return ImageInfo(
      image: image,
      scale: key.scale,
    );
  }

  @override
  String toString() => '$runtimeType(${describeIdentity(path)})';

  static Color getFilterColor(Color color) {
    if (kIsWeb && color == Colors.transparent) {
      return const Color(0x01ffffff);
    } else {
      return color;
    }
  }
}

@immutable
class SvgImageKey {
  const SvgImageKey({
    required this.path,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.scale,
    required this.source,
    this.color,
    this.svgGetter,
  });

  final String path;

  final int pixelWidth;

  final int pixelHeight;

  final Color? color;

  final SvgSource source;

  final double scale;

  final SvgStringGetter? svgGetter;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgImageKey &&
        other.path == path &&
        other.pixelWidth == pixelWidth &&
        other.pixelHeight == pixelHeight &&
        other.scale == scale &&
        other.source == source &&
        other.svgGetter == svgGetter;
  }

  @override
  int get hashCode =>
      Object.hash(path, pixelWidth, pixelHeight, scale, source, svgGetter);

  @override
  String toString() => '${objectRuntimeType(this, 'SvgImageKey')}'
      '(path: "$path", pixelWidth: $pixelWidth, pixelHeight: $pixelHeight, scale: $scale, source: $source)';
}
