import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImagehandeler extends StatefulWidget {
  NetworkImagehandeler(
    String url, {
    Key? key,
    Widget? placeholder,
    Widget? errorWidget,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool matchTextDirection = false,
    bool allowDrawingOutsideViewBox = false,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    Duration fadeDuration = const Duration(milliseconds: 300),
    ColorFilter? colorFilter,
    WidgetBuilder? placeholderBuilder,
  })  : _url = url,
        _placeholder = placeholder,
        _errorWidget = errorWidget,
        _width = width,
        _height = height,
        _fit = fit,
        _alignment = alignment,
        _matchTextDirection = matchTextDirection,
        _allowDrawingOutsideViewBox = allowDrawingOutsideViewBox,
        _color = color,
        _colorBlendMode = colorBlendMode,
        _semanticsLabel = semanticsLabel,
        _excludeFromSemantics = excludeFromSemantics,
        _theme = theme,
        _fadeDuration = fadeDuration,
        _colorFilter = colorFilter,
        _placeholderBuilder = placeholderBuilder,
        super(key: key ?? ValueKey(url));

  final String _url;
  final Widget? _placeholder;
  final Widget? _errorWidget;
  final double? _width;
  final double? _height;
  final BoxFit _fit;
  final AlignmentGeometry _alignment;
  final bool _matchTextDirection;
  final bool _allowDrawingOutsideViewBox;
  final Color? _color;
  final BlendMode _colorBlendMode;
  final String? _semanticsLabel;
  final bool _excludeFromSemantics;
  final SvgTheme _theme;
  final Duration _fadeDuration;
  final ColorFilter? _colorFilter;
  final WidgetBuilder? _placeholderBuilder;

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

class _NetworkImagehandelerState extends State<NetworkImagehandeler> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isError = false;
  File? _imageFile;
  late String _cacheKey;

  late final DefaultCacheManager _cacheManager;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _cacheKey = NetworkImagehandeler._generateKeyFromUrl(widget._url);
    super.initState();
    _cacheManager = DefaultCacheManager();
    _controller = AnimationController(
      vsync: this,
      duration: widget._fadeDuration,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      _setToLoadingAfter15MsIfNeeded();

      var file = (await _cacheManager.getFileFromMemory(_cacheKey))?.file;

      file ??= await _cacheManager.getSingleFile(widget._url, key: _cacheKey);

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
      width: widget._width,
      height: widget._height,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (_isLoading) return _buildPlaceholderWidget();

    if (_isError) return _buildErrorWidget();

    return FadeTransition(
      opacity: _animation,
      child: _returnImage(),
    );
  }

  Widget _buildPlaceholderWidget() => Center(child: widget._placeholder ?? const SizedBox());

  Widget _buildErrorWidget() => Center(child: widget._errorWidget ?? const SizedBox());

  Widget _buildSVGImage() {
    return SvgPicture.file(
      _imageFile!,
      fit: widget._fit,
      width: widget._width,
      height: widget._height,
      alignment: widget._alignment,
      matchTextDirection: widget._matchTextDirection,
      allowDrawingOutsideViewBox: widget._allowDrawingOutsideViewBox,
      color: widget._color,
      colorBlendMode: widget._colorBlendMode,
      semanticsLabel: widget._semanticsLabel,
      excludeFromSemantics: widget._excludeFromSemantics,
      colorFilter: widget._colorFilter,
      placeholderBuilder: widget._placeholderBuilder,
      theme: widget._theme,
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
          final ratio = MediaQuery.of(context).size.width / snapshot.data!.width;
          calWidth = ratio * snapshot.data!.width;
          calHeight = ratio * snapshot.data!.height;
        }
        return CircleAvatar(
          radius: 100,
          child: ClipOval(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                _imageFile!,
                height: widget._height ?? calHeight,
                width: widget._width ?? calWidth,
                fit: widget._fit,
              ),
            ),
          ),
        );
      },
    );
  }
}