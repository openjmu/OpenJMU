///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-19 15:27
///
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:extended_image/extended_image.dart';

class ExtendedTypedNetworkImageProvider extends ExtendedNetworkImageProvider {
  ExtendedTypedNetworkImageProvider(String url) : super(url);
  NetworkImageType _type;
  NetworkImageType get type => _getType(rawImageData) ?? _type;

  @override
  Future<ui.Codec> instantiateImageCodec(Uint8List data, DecoderCallback decode) async {
    _type = _getType(data);
    return super.instantiateImageCodec(data, decode);
  }

  NetworkImageType _getType(Uint8List data) {
    NetworkImageType _type;
    if (data != null) {
      final c = data.elementAt(0);
      switch (c) {
        case 0xFF:
          _type = NetworkImageType.jpg;
          break;
        case 0x89:
          _type = NetworkImageType.png;
          break;
        case 0x47:
          _type = NetworkImageType.gif;
          break;
        case 0x49:
        case 0x4D:
          _type = NetworkImageType.tiff;
          break;
        default:
          _type = NetworkImageType.other;
          break;
      }
    }
    return _type;
  }
}

enum NetworkImageType { jpg, png, gif, tiff, other }
