library cached_network_svg_image;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_img/src/svg_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CachedNetworkSVGImage extends StatefulWidget {
  const CachedNetworkSVGImage({
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
     this.fit,
     this.alignment,
     this.matchTextDirection,
     this.allowDrawingOutsideViewBox,
    this.color,
     this.colorBlendMode,
    this.semanticsLabel,
     this.excludeFromSemantics,
     this.theme,
     this.fadeDuration,
    this.colorFilter,
    this.placeholderBuilder,
    required this.url,
  });

  final String url;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;
  final bool? matchTextDirection;
  final bool? allowDrawingOutsideViewBox;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticsLabel;
  final bool? excludeFromSemantics;
  final SvgTheme? theme;
  final Duration? fadeDuration;
  final ColorFilter? colorFilter;
  final WidgetBuilder? placeholderBuilder;

  @override
  State<CachedNetworkSVGImage> createState() => _CachedNetworkSVGImageState();

  static Future<void> preCache(String imageUrl) {
    final key = _generateKeyFromUrl(imageUrl);
    return DefaultCacheManager().downloadFile(key);
  }

  static Future<void> clearCacheForUrl(String imageUrl) {
    final key = _generateKeyFromUrl(imageUrl);
    return DefaultCacheManager().removeFile(key);
  }

  static Future<void> clearCache() => DefaultCacheManager().emptyCache();

  static String _generateKeyFromUrl(String url) => url.split('?').first;
}

class _CachedNetworkSVGImageState extends State<CachedNetworkSVGImage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isError = false;
  late File? _imageFile;
  late String _cacheKey;

  late final DefaultCacheManager _cacheManager;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _cacheKey = CachedNetworkSVGImage._generateKeyFromUrl(widget.url);
    super.initState();
    _cacheManager = DefaultCacheManager();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration ?? Duration(milliseconds: 200),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = await _cacheManager.getSingleFile(widget.url, key: _cacheKey);
      setState(() {
        _imageFile = file;
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      log('CachedNetworkSVGImage: $e');
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (_isLoading) return _buildPlaceholderWidget();

    if (_isError) return _buildErrorWidget();

    return FadeTransition(
      opacity: _animation,
      child: _buildNetworkImage(),
    );
  }

  Widget _buildPlaceholderWidget() => Center(child: widget.placeholder ?? const SizedBox());

  Widget _buildErrorWidget() => Center(child: widget.errorWidget ?? const SizedBox());

  Widget _buildNetworkImage() {
    final svgExtRegX = RegExp(r'\.(svg)(?:\?.*|)$');
    if (svgExtRegX.hasMatch(widget.url)) {
      return _buildNetworkSvgImage();
    } else {
      return _buildNetWorkImage();
    }
  }

  Widget _buildNetworkSvgImage() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: SvgProvider(_imageFile!.path), //TODO: need to fix Unable to load asset
        ),
      ),
    );
  }

  Widget _buildNetWorkImage() {
    print(_imageFile!.path);
    double? calHeight = 0;
    double? calWidth = 0;
    final Image image = Image.file(_imageFile!);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );
    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          final ratio = MediaQuery.of(context).size.width / snapshot.data!.width;
          calWidth = ratio * snapshot.data!.width;
          calHeight = ratio * snapshot.data!.height;
        }
        return Container(
          height: widget.height ?? calHeight,
          width: widget.width ?? calWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(_imageFile!),
              fit: widget.fit,
              colorFilter: widget.colorFilter,
            ),
          ),
        );
      },
    );
  }
}
