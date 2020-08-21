import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://user-qr-code',
  routeName: '用户二维码页',
  pageRouteType: PageRouteType.transparent,
)
class UserQrCodePage extends StatefulWidget {
  @override
  _UserQrCodePageState createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  final GlobalKey previewContainer = GlobalKey();
  bool isSaving = false;
  double get minWidth => math.min(Screens.width, Screens.height);

  void saveToGallery() async {
    if (isSaving) {
      return;
    }
    isSaving = true;

    try {
      final bool isAllGranted = await checkPermissions(
        <Permission>[Permission.storage],
      );
      if (!isAllGranted) {
        showToast('未获得存储权限');
        return;
      }
      RenderRepaintBoundary boundary =
          previewContainer.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final result =
          await ImageSave.saveImage(byteData.buffer.asUint8List(), "png");
      if (result != null) {
        showToast('保存成功');
      } else {
        showToast('保存失败');
      }
    } catch (e) {
      isSaving = false;
      showToast('保存失败');
    }
  }

  Widget get usernameWidget {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0.w),
        child: Text(
          currentUser.name,
          style: TextStyle(color: Colors.white, fontSize: 22.0.sp),
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  Widget get qrImage {
    return Padding(
      padding: EdgeInsets.all(minWidth / 20),
      child: QrImage(
        version: 3,
        data: '${Routes.openjmuUserPage}/${currentUser.uid}',
        padding: EdgeInsets.zero,
        backgroundColor: context.themeData.colorScheme.surface,
        foregroundColor: context.themeData.textTheme.bodyText2.color,
        embeddedImage: AssetImage(R.IMAGES_LOGO_1024_ROUNDED_PNG),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size.square(minWidth * 0.1),
        ),
      ),
    );
  }

  Widget get saveButton {
    return GestureDetector(
      onTap: saveToGallery,
      child: Container(
        margin: EdgeInsets.only(top: minWidth / 10),
        width: 80.0.w,
        height: 80.0.w,
        decoration: BoxDecoration(
          color: context.themeData.canvasColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            R.ASSETS_ICONS_USER_SAVE_CODE_SVG,
            color: context.themeData.dividerColor.withOpacity(0.3),
            width: minWidth * 0.05,
            height: minWidth * 0.05,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: Navigator.of(context).pop,
            child: const SizedBox.expand(),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: previewContainer,
                  child: Container(
                    width: minWidth / 1.5,
                    padding: EdgeInsets.all(25.0.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0.w),
                      color: context.themeData.colorScheme.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            UserAvatar(size: 64.0),
                            usernameWidget,
                            sexualWidget(margin: EdgeInsets.zero),
                          ],
                        ),
                        SizedBox(height: 30.0.w),
                        qrImage,
                      ],
                    ),
                  ),
                ),
                saveButton,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
