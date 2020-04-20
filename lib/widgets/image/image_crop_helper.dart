import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import "package:isolate/load_balancer.dart";
import "package:isolate/isolate_runner.dart";
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';

final Future<LoadBalancer> loadBalancer =
    LoadBalancer.create(1, IsolateRunner.spawn);

Future<dynamic> isolateDecodeImage(List<int> data) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateDecodeImage, response.sendPort);
  final SendPort sendPort = await response.first as SendPort;
  final ReceivePort answer = ReceivePort();
  sendPort.send(<dynamic>[answer.sendPort, data]);
  return answer.first;
}

void _isolateDecodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final List<int> data = message[1] as List<int>;
    send.send(decodeImage(data));
  });
}

Future<dynamic> isolateEncodeImage(Image src) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateEncodeImage, response.sendPort);
  final SendPort sendPort = await response.first as SendPort;
  final ReceivePort answer = ReceivePort();
  sendPort.send(<dynamic>[answer.sendPort, src]);
  return answer.first;
}

void _isolateEncodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final Image src = message[1] as Image;
    send.send(encodeJpg(src));
  });
}

Future<List<int>> cropImage({ExtendedImageEditorState state}) async {
  final Rect cropRect = state.getCropRect();
  final EditActionDetails action = state.editAction;

  final int rotateAngle = action.rotateAngle.toInt();
  final bool flipHorizontal = action.flipY;
  final bool flipVertical = action.flipX;
  final Uint8List img = state.rawImageData;

  final ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect));
  }

  if (action.needFlip) {
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  final Uint8List result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );
  return result;
}
