///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-19 15:27
///
import 'dart:typed_data';
import 'dart:ui' as ui;

// ignore: implementation_imports
import 'package:extended_image_library/src/_network_image_io.dart';
import 'package:flutter/painting.dart';

class ExtendedTypedNetworkImageProvider extends ExtendedNetworkImageProvider {
  ExtendedTypedNetworkImageProvider(String url)
      : super(url, cacheRawData: true);

  ImageFileType? _imageType;

  ImageFileType get imageType => _imageType ?? _getType(rawImageData);

  @override
  Future<ui.Codec> instantiateImageCodec(
    Uint8List data,
    DecoderCallback decode,
  ) async {
    _imageType = _getType(data);
    return super.instantiateImageCodec(data, decode);
  }

  ImageFileType _getType(Uint8List data) {
    final int c = data.elementAt(0);
    switch (c) {
      case 0xFF:
        return ImageFileType.jpg;
      case 0x89:
        return ImageFileType.png;
      case 0x47:
        return ImageFileType.gif;
      case 0x49:
      case 0x4D:
        return ImageFileType.tiff;
      default:
        return ImageFileType.other;
    }
  }
}

enum ImageFileType { jpg, png, gif, tiff, other }
