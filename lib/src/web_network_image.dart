
import 'package:flutter/cupertino.dart';
import 'package:flutter_img/src/web_mime_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// [WebNetworkImageHandler] will handel all network image
class WebNetworkImageHandler extends StatefulWidget {
  /// for [WebNetworkImageHandler], [WebNetworkImageHandler.src] is required
  const WebNetworkImageHandler(
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
  });

  /// `src` is the network image source for [WebNetworkImageHandler].
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

  @override
  State<WebNetworkImageHandler> createState() => _WebNetworkImageHandlerState();
}

class _WebNetworkImageHandlerState extends State<WebNetworkImageHandler> {
  ImgFile? imgFile;

  @override
  void initState() {
    super.initState();
    fgdfg();
  }

  Future<void> fgdfg() async {
    final response = await http.get(Uri.parse(
        'https://miro.medium.com/v2/resize:fit:4800/0*bDz2chibrm3B6QZE',),);

    // https://miro.medium.com/v2/resize:fit:4800/0*bDz2chibrm3B6QZE
    // https://raw.githubusercontent.com/shafi-org/portfolio/master/src/assets/flutter-svgrepo-com.svg
    final data = getFile(response);
    setState(() {
      imgFile = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(imgFile == null){
      return const SizedBox();
    }
    if (imgFile!.fileType == ImgMimeType.svg) {
      return SvgPicture.memory(imgFile!.file);
    }
    return Image.memory(imgFile!.file);
  }
}
