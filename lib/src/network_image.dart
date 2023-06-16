import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_img/src/shapes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImagehandeler extends StatefulWidget {
  NetworkImagehandeler(
    this.src, {
    this.placeholder,
    this.colorFilter,
    this.width,
    this.height,
    this.errorWidget,
    this.blurHash,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.border,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.shape,
  });

  final String src;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? blurHash;
  final double? width;
  final double? height;
  final Duration? fadeDuration;
  final ColorFilter? colorFilter;
  final BoxShape? shape;
  final Color? backgroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<NetworkImagehandeler> createState() => _NetworkImagehandelerState();

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

class _NetworkImagehandelerState extends State<NetworkImagehandeler>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isError = false;
  bool isPlaceholderLoaded = false;
  File? _imageFile;
  late String _cacheKey;

  late final DefaultCacheManager _cacheManager;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _cacheKey = NetworkImagehandeler._generateKeyFromUrl(widget.src);
    super.initState();
    _cacheManager = DefaultCacheManager();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      _setToLoadingAfter15MsIfNeeded();

      var file = (await _cacheManager.getFileFromMemory(_cacheKey))?.file;

      file ??= await _cacheManager.getSingleFile(widget.src, key: _cacheKey);

      _imageFile = file;
      _isLoading = false;

      _setState();

      await _controller.forward();
    } catch (e) {
      log('CachedNetworkSVGImage: $e');

      _isError = true;
      _isLoading = false;

      _setState();
    }
  }

  void _setToLoadingAfter15MsIfNeeded() => Future.delayed(
        const Duration(milliseconds: 15),
        () {
          if (!_isLoading && _imageFile == null && !_isError) {
            _isLoading = true;
            _setState();
          }
        },
      );

  void _setState() => mounted ? setState(() {}) : null;

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
    if (_isLoading) {
      return _buildPlaceholderWidget();
    }

    if (_isError) return _buildErrorWidget();
    return FadeTransition(
      opacity: _animation,
      child: _returnImage(),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Center(
      child: SizedBox(
        height: widget.height ?? 200,
        width: widget.width ?? 200,
        child: widget.placeholder ??
            BlurHash(
              hash: widget.blurHash ?? 'L5H2EC=PM+yV0g-mq.wG9c010J}I',
            ),
      ),
    );
  }

  Widget _buildErrorWidget() => Center(
        child: widget.errorWidget ??
            const SizedBox(
              child: Text('Error loading Image'),
            ),
      );

  Widget _buildSVGImage() {
    return ImageShape(
      shape: widget.shape,
      border: widget.border,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      margin: widget.margin,
      colorFilter: widget.colorFilter,
      borderRadius: widget.borderRadius,
      child: SvgPicture.file(
        _imageFile!,
      ),
    );
  }

  Widget _returnImage() {
    if (_imageFile == null) return const SizedBox();
    if (_getFileExtension(_imageFile!.path) == '.svg') {
      return _buildSVGImage();
      //
    } else {
      return _buildNetworkImage();
    }
  }

  String _getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Widget _buildNetworkImage() {
    double? calHeight = 0;
    double? calWidth = 0;
    final image = Image.file(_imageFile!);
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
          height: widget.height ?? calHeight,
          width: widget.width ?? calWidth,
          shape: widget.shape,
          border: widget.border,
          padding: widget.padding,
          margin: widget.margin,
          borderRadius: widget.borderRadius,
          colorFilter: widget.colorFilter,
          backgroundColor: widget.backgroundColor,
          child: Image.file(
            _imageFile!,
            height: widget.height ?? calHeight,
            width: widget.width ?? calWidth,
          ),
        );
      },
    );
  }
}
