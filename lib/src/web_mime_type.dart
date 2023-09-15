import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:mime/mime.dart';

ImgFile getFile(Response response) {
  ImgMimeType type;
  final Uint8List file;
  final mime = lookupMimeType('', headerBytes: response.bodyBytes);
  if (response.body.contains('</svg>')) {
    type = ImgMimeType.svg;
  } else {
    if (mime != null) {
      if (extensionFromMime(mime) == 'png') {
        type = ImgMimeType.png;
      } else if (extensionFromMime(mime) == 'jpg') {
        type = ImgMimeType.jpg;
      } else if (extensionFromMime(mime) == 'jpeg') {
        type = ImgMimeType.jpeg;
      } else if (extensionFromMime(mime) == 'gif') {
        type = ImgMimeType.gif;
      } else {
        type = ImgMimeType.notValid;
      }
    } else {
      type = ImgMimeType.notValid;
    }
  }
  file = response.bodyBytes;
  return ImgFile(fileType: type, file: file);
}

enum ImgMimeType { svg, png, jpg, jpeg, gif, notValid }

class ImgFile {
  ImgFile({required this.fileType, required this.file});

  ImgMimeType fileType;
  Uint8List file;
}
