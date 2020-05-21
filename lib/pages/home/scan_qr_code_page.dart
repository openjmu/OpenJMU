///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/5/12 16:05
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:r_scan/r_scan.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://scan-qr-code', routeName: '扫描二维码')
class ScanQrCodePage extends StatefulWidget {
  @override
  _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  /// List for available cameras.
  /// 可用的相机列表
  List<RScanCameraDescription> rScanCameras = <RScanCameraDescription>[];

  /// Controller for [RScanCameraDescription].
  /// 相机控制器
  RScanCameraController _controller;

  /// Get first camera from list. Return `null` if there's non.
  /// 获取第一个相机实例，如果没有则返回 `null`。
  RScanCameraDescription get firstCameraDescription =>
      rScanCameras.isNotEmpty ? rScanCameras.first : null;

  /// Store scan result as a variable.
  /// 将扫码结果以变量方式保存
  RScanResult scanResult;

  /// Whether there's no camera for scanning.
  /// 是否无相机可用
  bool isCamerasEmpty = false;

  /// Whether the camera controller has been initialized.
  /// 判断相机控制器是否已初始化完成
  ///
  /// Using it for widget initialize, or the widget will throw
  /// calling on null error.
  /// 若不在判断后构建部件，会抛出空调用
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    fetchCameras();
  }

  @override
  void dispose() {
    _controller?.stopScan();
    _controller?.dispose();
    super.dispose();
  }

  /// Check available cameras then initialize / bing listener.
  /// 获取可用的相机后初始化 & 绑定回调
  void fetchCameras() {
    availableRScanCameras().then((List<RScanCameraDescription> s) {
      rScanCameras = s;
      if (firstCameraDescription != null) {
        _controller = RScanCameraController(
          firstCameraDescription,
          RScanCameraResolutionPreset.max,
        )
          ..addListener(onScan)
          ..initialize().then((dynamic _) {
            if (mounted) {
              setState(() {
                if (!isCameraInitialized) {
                  isCameraInitialized = true;
                }
              });
            }
          });
      } else {
        isCamerasEmpty = true;
        if (mounted) {
          setState(() {});
        }
      }
    }).catchError((dynamic e) {
      isCamerasEmpty = true;
      if (mounted) {
        setState(() {});
      }
      trueDebugPrint('Failed when fetching cameras: $e');
    });
  }

  /// Callback for scanner result.
  /// 扫描得到结果时的回调
  Future<void> onScan({bool isFromFile = false}) async {
    if (!isFromFile) {
      scanResult = _controller.result;
    }
    if (scanResult == null) {
      if (isFromFile) {
        showToast('未从图片中扫描到结果');
      }
      return;
    }
    unawaited(_controller.stopScan());

    if (API.urlReg.stringMatch(scanResult.message) != null) {
      /// Launch web page if a common url was detected.
      /// 如果检测到常见的url格式内容则打开网页
      Navigator.of(context).pop();
      unawaited(API.launchWeb(url: '${scanResult.message}'));
    } else if (API.schemeUserPage.stringMatch(scanResult.message) != null) {
      /// Push to user page if a user scheme is detected.
      /// 如果检测到用户scheme则跳转到用户页
      unawaited(Navigator.of(context).pushReplacementNamed(
        Routes.openjmuUser,
        arguments: <String, dynamic>{
          'uid': scanResult.message
              .substring(API.schemeUserPage.pattern.length - 2)
              .toInt()
        },
      ));
    } else {
      final bool needCopy = await ConfirmationDialog.show(
        context,
        title: '扫码结果',
        content: '${scanResult.message}',
        showConfirm: true,
        confirmLabel: '复制',
        cancelLabel: '返回',
      );
      if (needCopy) {
        unawaited(
          Clipboard.setData(ClipboardData(text: '${scanResult.message}')),
        );
      }
      unawaited(_controller.startScan());
    }
  }

  /// Scan QR code from file.
  /// 从文件中扫描二维码
  Future<void> scanFromFile() async {
    final File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    try {
      final RScanResult result = await RScan.scanImagePath(file.path);
      scanResult = result;
      unawaited(onScan(isFromFile: true));
    } catch (e) {
      showToast('扫码出错');
    }
  }

  /// 用户的二维码
  Widget get userQrCode => Positioned(
        left: Screens.width / 3.5,
        right: Screens.width / 3.5,
        bottom: Screens.width / 3.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                '我的二维码',
                style: TextStyle(fontSize: 24.0.sp, color: Colors.white),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(24.0),
              child: QrImage(
                version: 3,
                data: 'openjmu://user/${currentUser.uid}',
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );

  /// 顶栏
  Widget get appBar => PositionedDirectional(
        top: Screens.topSafeHeight + 8.0,
        start: 8.0,
        end: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[backButton, importFromGalleryButton],
        ),
      );

  /// 返回键
  Widget get backButton => BackButton(color: Colors.white);

  /// 选择图库文件进行扫描
  Widget get importFromGalleryButton => IconButton(
        icon: Icon(Icons.perm_media, color: Colors.white),
        onPressed: scanFromFile,
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: Colors.black,
        child: _controller != null && isCameraInitialized
            ? Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: RScanCamera(_controller),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      size: Size(Screens.width, Screens.height),
                      painter: ScannerPainter(borderRadius: 20.0),
                    ),
                  ),
                  userQrCode,
                  appBar,
                ],
              )
            : Center(
                child: Text(
                  isCamerasEmpty
                      ? 'No camera was ready for scannning.'
                      : 'Preparing camera...',
                ),
              ),
      ),
    );
  }
}

class ScannerPainter extends CustomPainter {
  ScannerPainter({this.borderRadius = 0.0});

  final double borderRadius;

  double get borderWidth => 10.0.w;
  double get padding => Screens.width / 3.5 + borderWidth / 2;
  double get length => Screens.width - padding * 2;
  Rect get rect => Rect.fromLTWH(
        padding,
        padding + Screens.topSafeHeight,
        length,
        length,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();

    /// Draw outer area first.
    path.moveTo(0, 0);
    path.lineTo(Screens.width, 0);
    path.lineTo(Screens.width, Screens.height);
    path.lineTo(0, Screens.height);
    path.lineTo(0, 0);
    path.close();

    /// Draw inside area.
    path.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
    );
    path.close();

    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black38);

    /// Draw rounded border.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 10.0.w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
