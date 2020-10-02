///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/5/12 16:05
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:r_scan/r_scan.dart';
import 'package:vibration/vibration.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://scan-qr-code', routeName: '扫描二维码')
class ScanQrCodePage extends StatefulWidget {
  @override
  _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage>
    with TickerProviderStateMixin {
  final TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16.0.sp,
  );

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
  /// Using it for the widget initialize, or the widget will throw
  /// calling on null error.
  /// 若不在判断后构建部件，会抛出空调用
  bool isCameraInitialized = false;

  /// Whether user's qr code is displaying.
  /// 用户的二维码是否正在显示
  bool isDisplayingUserQrCode = false;

  /// These variables control the animation of the grid shader.
  /// 下面的变量用于控制
  final StreamController<double> shaderTranslateStream =
      StreamController<double>.broadcast();
  Animation<double> shaderAnimation;
  AnimationController shaderAnimationController;

  @override
  void initState() {
    super.initState();
    fetchCameras();
    initShaderAnimation();
  }

  @override
  void dispose() {
    shaderTranslateStream.close();
    shaderAnimationController
      ..stop()
      ..dispose();
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
  Future<void> onScan({RScanResult result, fromAlbum = false}) async {
    scanResult = result ?? _controller.result;
    if (scanResult == null) {
      if (fromAlbum) {
        showToast('未从图片中扫描到结果');
      }
      return;
    }

    /// Stop scan immediately.
    /// 立刻停止扫描
    unawaited(_controller.stopScan());

    /// Call vibrate once.
    /// 振动
    unawaited(
      Vibration.hasVibrator().then((bool hasVibrator) {
        if (hasVibrator) {
          Vibration.vibrate(duration: 100, intensities: <int>[100]);
        }
      }),
    );

    if (API.urlReg.stringMatch(scanResult.message) != null) {
      /// Launch web page if a common url was detected.
      /// 如果检测到常见的url格式内容则打开网页
      Navigator.of(context).pop();
      unawaited(API.launchWeb(url: '${scanResult.message}'));
    } else if (API.schemeUserPage.stringMatch(scanResult.message) != null) {
      /// Push to user page if a user scheme is being detect.
      /// 如果检测到用户scheme则跳转到用户页
      unawaited(Navigator.of(context).pushReplacementNamed(
        Routes.openjmuUserPage,
        arguments: <String, dynamic>{
          'uid': scanResult.message
              .substring(API.schemeUserPage.pattern.length - 2)
              .toInt()
        },
      ));
    } else {
      /// Other types of result will show a dialog to copy.
      /// 其他类型的结果会以弹窗形式提供复制
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
    _controller.result = null;
  }

  /// Initialize animation for grid shader.
  /// 为网格效果初始化动画
  void initShaderAnimation() {
    shaderAnimationController = AnimationController(
      duration: 3.seconds,
      vsync: this,
    );
    shaderAnimation = Tween<double>(
      begin: -Screens.height,
      end: Screens.height * 0.5,
    ).animate(shaderAnimationController)
      ..addListener(() {
        shaderTranslateStream.add(shaderAnimation.value);
      });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      shaderAnimationController.repeat();
    });
  }

  /// Switch user's qr code display status.
  /// 切换用户二维码的显示状态
  void switchUserQrCodeDisplay() {
    setState(() {
      isDisplayingUserQrCode = !isDisplayingUserQrCode;
    });
  }

  /// Scan QR code from the file.
  /// 从文件中扫描二维码
  Future<void> scanFromFile() async {
    unawaited(_controller.stopScan());
    final List<AssetEntity> entity = await AssetPicker.pickAssets(
      context,
      maxAssets: 1,
      themeColor: currentThemeColor,
      requestType: RequestType.image,
    );
    if (entity?.isEmpty ?? true) {
      return;
    }
    try {
      final RScanResult result = await RScan.scanImagePath(
        (await entity.first.originFile).path,
      );
      unawaited(onScan(result: result, fromAlbum: true));
    } catch (e) {
      showToast('扫码出错');
      unawaited(_controller.startScan());
    }
  }

  /// Animating shader grid layout.
  /// 闪烁格子布局
  Widget get animatingGrid => Positioned.fill(
        child: StreamBuilder(
          initialData: 0.0,
          stream: shaderTranslateStream.stream,
          builder: (BuildContext _, AsyncSnapshot<double> data) {
            return ShaderMask(
              shaderCallback: (Rect rect) {
                final Gradient gradient = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.transparent,
                    currentThemeColor,
                    Colors.transparent,
                  ],
                  stops: <double>[0.0, 0.75, 0.99, 1.0],
                  transform: GradientTranslateTransform(
                    Offset(0, data.data),
                  ),
                );
                return gradient.createShader(rect);
              },
              child: GridPaper(
                color: currentThemeColor.withOpacity(0.75),
              ),
            );
          },
        ),
      );

  /// 用户的二维码
  Widget get userQrCode => AnimatedPositioned(
        duration: kThemeAnimationDuration,
        left: Screens.width / 3.5,
        right: Screens.width / 3.5,
        bottom: isDisplayingUserQrCode
            ? Screens.width / 3.5
            : Screens.bottomSafeHeight + 16.0,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: kThemeAnimationDuration,
          opacity: isDisplayingUserQrCode ? 1.0 : 0.0,
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
        ),
      );

  /// 顶栏
  Widget get appBar => PositionedDirectional(
        top: Screens.topSafeHeight + 8.0,
        start: 8.0,
        child: backButton,
      );

  /// 返回键
  Widget get backButton => BackButton(color: Colors.white);

  /// 个人码按钮
  Widget get selfQrCodeButton => PositionedDirectional(
        bottom: Screens.bottomSafeHeight,
        start: 0.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: switchUserQrCodeDisplay,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.person, color: Colors.white, size: 20.0),
                Text('个人码', style: buttonTextStyle),
              ],
            ),
          ),
        ),
      );

  /// 选择图库文件进行扫描
  Widget get importFromGalleryButton => PositionedDirectional(
        bottom: Screens.bottomSafeHeight,
        end: 0.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: scanFromFile,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.perm_media, color: Colors.white, size: 20.0),
                Text('相册', style: buttonTextStyle),
              ],
            ),
          ),
        ),
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
                  animatingGrid,
                  userQrCode,
                  appBar,
                  selfQrCodeButton,
                  importFromGalleryButton,
                ],
              )
            : Center(
                child: Text(
                  isCamerasEmpty
                      ? 'No camera was ready for scanning.'
                      : 'Preparing camera...',
                ),
              ),
      ),
    );
  }
}

class GradientTranslateTransform extends GradientTransform {
  GradientTranslateTransform(this.offset);

  final Offset offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection textDirection}) {
    return Matrix4.translationValues(offset.dx, offset.dy, 0.0);
  }
}
