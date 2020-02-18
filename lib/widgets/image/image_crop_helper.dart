import 'dart:isolate';
import "package:isolate/load_balancer.dart";
import "package:isolate/isolate_runner.dart";
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';

final loadBalancer = LoadBalancer.create(1, IsolateRunner.spawn);

Future<dynamic> isolateDecodeImage(List<int> data) async {
  final response = ReceivePort();
  await Isolate.spawn(_isolateDecodeImage, response.sendPort);
  final sendPort = await response.first;
  final answer = ReceivePort();
  sendPort.send([answer.sendPort, data]);
  return answer.first;
}

void _isolateDecodeImage(SendPort port) {
  final rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((message) {
    final send = message[0] as SendPort;
    final data = message[1] as List<int>;
    send.send(decodeImage(data));
  });
}

Future<dynamic> isolateEncodeImage(Image src) async {
  final response = ReceivePort();
  await Isolate.spawn(_isolateEncodeImage, response.sendPort);
  final sendPort = await response.first;
  final answer = ReceivePort();
  sendPort.send([answer.sendPort, src]);
  return answer.first;
}

void _isolateEncodeImage(SendPort port) {
  final rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((message) {
    final send = message[0] as SendPort;
    final src = message[1] as Image;
    send.send(encodeJpg(src));
  });
}

Future<List<int>> cropImage({ExtendedImageEditorState state}) async {
  final cropRect = state.getCropRect();
  final action = state.editAction;

  final rotateAngle = action.rotateAngle.toInt();
  final flipHorizontal = action.flipY;
  final flipVertical = action.flipX;
  final img = state.rawImageData;

  ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) option.addOption(ClipOption.fromRect(cropRect));

  if (action.needFlip) {
    option.addOption(FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );
  return result;
}
