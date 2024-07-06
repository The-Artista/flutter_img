import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_img/src/shapes.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// [NetworkImageHandler] will handel all network image
class NetworkImageHandler extends StatefulWidget {
  /// for [NetworkImageHandler], [NetworkImageHandler.src] is required
  const NetworkImageHandler(
    this.src, {
    super.key,
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
    this.fit = BoxFit.contain,
  });

  /// `src` is the network image source for [NetworkImageHandler].
  final String src;

  /// The placeholder parameter allows you to
  /// provide any widget as a placeholder before the network image
  /// is fully loaded.
  final Widget? placeholder;

  /// The errorWidget parameter allows you to
  /// provide any widget that will visible  if network request failed
  /// or any error happened during loading image
  final Widget? errorWidget;

  /// The blurHash parameter also allows you to load blurhash
  /// images before the network image is fully loaded.
  /// asset images not be affected.
  /// By default, if you don't provide placeholder blursh will apply.
  /// and the default value is L5H2EC=PM+yV0g-mq.wG9c010J}I
  final String? blurHash;

  /// `width` explicitly set image width.
  /// you can pass a height value or it will adjust the width
  /// based on image width and screen width
  final double? width;

  /// `height` explicitly set image height. you can pass a
  /// height value or it will adjust the height based on image
  /// height and screen height
  final double? height;

  /// transition time between placeholder and image
  final Duration? fadeDuration;

  /// The colorFilter allow you to set a color filter over the image
  final ColorFilter? colorFilter;

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

  final BoxFit fit;

  @override
  State<NetworkImageHandler> createState() => _NetworkImageHandlerState();

  /// create a cached image
  static Future<void> preCache(String imageUrl) {
    final key = _generateKeyFromUrl(imageUrl);
    return DefaultCacheManager().downloadFile(key);
  }

  /// clear specific image cache by image url
  static Future<void> clearCacheForUrl(String imageUrl) {
    final key = _generateKeyFromUrl(imageUrl);
    return DefaultCacheManager().removeFile(key);
  }

  /// clear Cache
  static Future<void> clearCache() => DefaultCacheManager().emptyCache();

  static String _generateKeyFromUrl(String url) => url.split('?').first;
}

class _NetworkImageHandlerState extends State<NetworkImageHandler>
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
    _cacheKey = NetworkImageHandler._generateKeyFromUrl(widget.src);
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
      height: widget.height,
      width: widget.width,
      shape: widget.shape,
      border: widget.border,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      margin: widget.margin,
      colorFilter: widget.colorFilter,
      borderRadius: widget.borderRadius,
      child: SvgPicture.file(
        _imageFile!,
        colorFilter: widget.colorFilter,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
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
            fit: widget.fit,
          ),
        );
      },
    );
  }
}
