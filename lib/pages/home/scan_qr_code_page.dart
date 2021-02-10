///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/5/12 16:05
///
import 'dart:async';

import 'package:flutter/material.dart';

// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:r_scan/r_scan.dart';
import 'package:vibration/vibration.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://scan-qr-code', routeName: '扫描二维码')
class ScanQrCodePage extends StatefulWidget {
  @override
  _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// List for available cameras.
  /// 可用的相机列表
  List<RScanCameraDescription> rScanCameras = <RScanCameraDescription>[];

  /// Controller for [RScanCameraDescription].
  /// 相机控制器
  RScanCameraController _controller;

  /// Get first camera from list. Return `null` if there're none.
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
  final ValueNotifier<bool> isDisplayingUserQrCode = ValueNotifier<bool>(false);

  /// Whether we should handle the scan result.
  /// 是否应该对扫码结果进行处理
  bool shouldHandleResult = true;

  /// These variables control the animation of the grid shader.
  /// 下面的变量用于控制网格动画的位置
  // final StreamController<double> shaderTranslateStream =
  //     StreamController<double>.broadcast();
  // Animation<double> shaderAnimation;
  // AnimationController shaderAnimationController;

  /// Adjust the proper scale type according to the [controller].
  /// 通过 [controller] 的预览大小，判断相机预览适用的缩放类型。
  _PreviewScaleType get _effectiveScaleType {
    assert(_controller != null);
    final Size _size = _controller.value.previewSize;
    final Size _scaledSize = _size * (Screens.widthPixels / _size.height);
    if (_scaledSize.width > Screens.heightPixels) {
      return _PreviewScaleType.width;
    } else if (_scaledSize.width < Screens.heightPixels) {
      return _PreviewScaleType.height;
    } else {
      return _PreviewScaleType.none;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchCameras();
    // initShaderAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        fetchCameras();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller.dispose();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // shaderTranslateStream.close();
    // shaderAnimationController
    //   ..stop()
    //   ..dispose();
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
      LogUtils.e('Failed when fetching cameras: $e');
    });
  }

  /// Callback for scanner result.
  /// 扫描得到结果时的回调
  Future<void> onScan({RScanResult result, bool fromAlbum = false}) async {
    if (!shouldHandleResult) {
      return;
    }

    scanResult = result ?? _controller.result;
    if (scanResult == null) {
      if (fromAlbum) {
        showToast('未从图片中扫描到结果');
      }
      return;
    }

    shouldHandleResult = false;

    /// Call vibrate once.
    /// 振动
    Vibration.hasVibrator().then((bool hasVibrator) {
      if (hasVibrator) {
        Vibration.vibrate(duration: 100, intensities: <int>[100]);
      }
    });

    if (API.urlReg.stringMatch(scanResult.message) != null) {
      /// Launch web page if a common url was detected.
      /// 如果检测到常见的url格式内容则打开网页
      Navigator.of(context).pop();
      API.launchWeb(url: scanResult.message);
    } else if (API.schemeUserPage.stringMatch(scanResult.message) != null) {
      /// Push to user page if a user scheme is being detect.
      /// 如果检测到用户 scheme 则跳转到用户页
      navigatorState.pushReplacementNamed(
        Routes.openjmuUserPage.name,
        arguments: Routes.openjmuUserPage.d(
          uid: scanResult.message
              .replaceAll(Routes.openjmuUserPage.name, '')
              .replaceAll('/', '')
              .trim(),
        ),
      );
    } else {
      /// Other types of result will show a dialog to copy.
      /// 其他类型的结果会以弹窗形式提供复制
      final bool needCopy = await ConfirmationDialog.show(
        context,
        title: '扫码结果',
        content: scanResult.message,
        showConfirm: true,
        confirmLabel: '复制',
        cancelLabel: '返回',
      );
      if (needCopy) {
        Clipboard.setData(ClipboardData(text: scanResult.message));
      }
      shouldHandleResult = true;
    }
    _controller.result = null;
  }

  /// Initialize animation for grid shader.
  /// 为网格效果初始化动画
  // void initShaderAnimation() {
  //   shaderAnimationController = AnimationController(
  //     duration: 3.seconds,
  //     vsync: this,
  //   );
  //   shaderAnimation = Tween<double>(
  //     begin: -Screens.height,
  //     end: Screens.height * 0.5,
  //   ).animate(shaderAnimationController)
  //     ..addListener(() {
  //       shaderTranslateStream.add(shaderAnimation.value);
  //     });
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     shaderAnimationController.repeat();
  //   });
  // }

  /// Switch user's qr code display status.
  /// 切换用户二维码的显示状态
  void switchUserQrCodeDisplay() {
    isDisplayingUserQrCode.value = !isDisplayingUserQrCode.value;
  }

  /// Scan QR code from the file.
  /// 从文件中扫描二维码
  Future<void> scanFromFile() async {
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
      onScan(result: result, fromAlbum: true);
    } catch (e) {
      showToast('扫码出错');
      shouldHandleResult = true;
    }
  }

  /// Animating shader grid layout.
  /// 闪烁格子布局
  // Widget get animatingGrid {
  //   return Positioned.fill(
  //     child: StreamBuilder<double>(
  //       initialData: 0.0,
  //       stream: shaderTranslateStream.stream,
  //       builder: (BuildContext _, AsyncSnapshot<double> data) {
  //         return ShaderMask(
  //           shaderCallback: (Rect rect) {
  //             final Gradient gradient = LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: <Color>[
  //                 Colors.transparent,
  //                 Colors.transparent,
  //                 currentThemeColor,
  //                 Colors.transparent,
  //               ],
  //               stops: const <double>[0.0, 0.75, 0.99, 1.0],
  //               transform: GradientTranslateTransform(
  //                 Offset(0, data.data),
  //               ),
  //             );
  //             return gradient.createShader(rect);
  //           },
  //           child: GridPaper(
  //             color: currentThemeColor.withOpacity(0.75),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  /// 顶栏
  Widget get appBar {
    return PositionedDirectional(
      top: Screens.topSafeHeight + 8.w,
      start: 8.w,
      child: backButton,
    );
  }

  /// 返回键
  Widget get backButton => const BackButton(color: Colors.white);

  /// 选择图库文件进行扫描
  Widget get importFromGalleryButton {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: scanFromFile,
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Text(
          '从相册中选取',
          style: TextStyle(color: Colors.white70, fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget _previewBuilder(BuildContext context) {
    assert(_controller != null);

    Widget _preview = RScanCamera(_controller);

    if (_effectiveScaleType == _PreviewScaleType.none) {
      return _preview;
    }

    double _width;
    double _height;
    switch (_effectiveScaleType) {
      case _PreviewScaleType.width:
        _width = Screens.width;
        _height = Screens.width / _controller.value.aspectRatio;
        break;
      case _PreviewScaleType.height:
        _width = Screens.height * _controller.value.aspectRatio;
        _height = Screens.height;
        break;
      default:
        _width = Screens.width;
        _height = Screens.height;
        break;
    }
    final double _offsetHorizontal = (_width - Screens.width).abs() / -2;
    final double _offsetVertical = (_height - Screens.height).abs() / -2;
    _preview = Stack(
      children: <Widget>[
        Positioned(
          left: _offsetHorizontal,
          right: _offsetHorizontal,
          top: _offsetVertical,
          bottom: _offsetVertical,
          child: _preview,
        ),
      ],
    );
    return _preview;
  }

  Widget _scanPainter({
    @required double size,
    @required double radius,
    @required double top,
    Widget child,
  }) {
    return CustomPaint(
      painter: ScanRectPainter(
        size: Size.square(size),
        radius: radius,
        top: top,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: size + top),
          if (child != null) Expanded(child: child) else const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            if (_controller != null && isCameraInitialized)
              Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(child: _previewBuilder(context)),
                  Positioned.fill(
                    child: _scanPainter(
                      size: Screens.width / 2,
                      radius: 12.w,
                      top: Screens.width / 2.75,
                      child: Column(
                        children: <Widget>[
                          VGap(40.w),
                          Text(
                            '请将摄像头对准二维码',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.sp,
                            ),
                          ),
                          const Spacer(),
                          importFromGalleryButton,
                          VGap(60.w),
                        ],
                      ),
                    ),
                  ),
                  appBar,
                ],
              )
            else
              Center(
                child: Text(
                  isCamerasEmpty ? '暂无可用的相机' : '准备中......',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            appBar,
          ],
        ),
      ),
    );
  }
}

/// 使用非零填充环绕实现的矩形镂空
///
/// [height] 镂空的高度
/// [paddingOffset] 镂空区域距离起始点的偏移量，且作为边距
class ScanRectPainter extends CustomPainter {
  const ScanRectPainter({
    @required this.size,
    @required this.radius,
    this.top,
  })  : assert(size != null),
        assert(radius != null);

  final Size size;
  final double radius;
  final double top;

  void drawInnerRect(Canvas c, Size s) {
    assert(size < Size(Screens.width, Screens.height));
    final Path path = Path()..fillType = PathFillType.evenOdd;
    // 先画外部矩形
    path
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    // 再画内部矩形
    final double _horizontalGap = (s.width - size.width) / 2;
    final double _topGap = top ?? kAppBarHeight.w;
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_horizontalGap, _topGap, size.width, size.height),
        Radius.circular(radius),
      ),
    );
    // Canvas 绘制路径
    c.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 10.w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.fill,
    );
  }

  void drawBorder(Canvas c, Size s) {
    final double _horizontalGap = (s.width - size.width) / 2;
    final double _topGap = top ?? kAppBarHeight.w;
    // 绘制外框
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          _horizontalGap,
          _topGap,
          s.width - _horizontalGap * 2,
          size.height,
        ),
        Radius.circular(radius),
      ),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 3.w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawInnerRect(canvas, size);
    drawBorder(canvas, size);
  }

  @override
  bool shouldRepaint(ScanRectPainter oldDelegate) =>
      size != oldDelegate.size ||
      radius != oldDelegate.radius ||
      top != oldDelegate.top;
}

class GradientTranslateTransform extends GradientTransform {
  const GradientTranslateTransform(this.offset);

  final Offset offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection textDirection}) {
    return Matrix4.translationValues(offset.dx, offset.dy, 0.0);
  }
}

enum _PreviewScaleType { none, width, height }
