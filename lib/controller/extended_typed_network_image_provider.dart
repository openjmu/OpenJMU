///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-19 15:27
///
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:extended_image_library/src/_network_image_io.dart';

class ExtendedTypedNetworkImageProvider extends ExtendedNetworkImageProvider {
  ExtendedTypedNetworkImageProvider(String url) : super(url);
  ImageFileType _imageType;
  ImageFileType get imageType => _imageType ?? _getType(rawImageData);

  @override
  Future<ui.Codec> instantiateImageCodec(
      Uint8List data, DecoderCallback decode) async {
    _imageType = _getType(data);
    return super.instantiateImageCodec(data, decode);
  }

  ImageFileType _getType(Uint8List data) {
    ImageFileType _type;
    if (data != null) {
      final c = data.elementAt(0);
      switch (c) {
        case 0xFF:
          _type = ImageFileType.jpg;
          break;
        case 0x89:
          _type = ImageFileType.png;
          break;
        case 0x47:
          _type = ImageFileType.gif;
          break;
        case 0x49:
        case 0x4D:
          _type = ImageFileType.tiff;
          break;
        default:
          _type = ImageFileType.other;
          break;
      }
    }
    return _type;
  }
}

enum ImageFileType { jpg, png, gif, tiff, other }
