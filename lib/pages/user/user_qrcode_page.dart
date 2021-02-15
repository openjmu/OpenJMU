import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://user-qr-code',
  routeName: '用户二维码页',
  pageRouteType: PageRouteType.transparent,
)
class UserQrCodePage extends StatefulWidget {
  const UserQrCodePage({Key key}) : super(key: key);

  @override
  _UserQrCodePageState createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  final GlobalKey previewContainer = GlobalKey();
  bool isSaving = false;

  double get minWidth => math.min(Screens.width, Screens.height);

  Future<void> saveToGallery() async {
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
      final RenderRepaintBoundary boundary = previewContainer.currentContext
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio,
      );
      final ByteData byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      await PhotoManager.editor.saveImage(byteData.buffer.asUint8List());
      showToast('保存成功');
    } catch (e) {
      showToast('保存失败');
    } finally {
      isSaving = false;
    }
  }

  Widget get qrImage {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: QrImage(
              version: 3,
              data: '${Routes.openjmuUserPage.name}/${currentUser.uid}',
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          Center(child: UserAvatar(size: minWidth / 7)),
        ],
      ),
    );
  }

  Widget _qrWidget(BuildContext context) {
    return RepaintBoundary(
      key: previewContainer,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Screens.width * 0.1,
        ),
        color: context.theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.w),
              child: SvgPicture.asset(
                R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
                color: defaultLightColor,
                width: Screens.width * 0.275,
              ),
            ),
            qrImage,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.w),
              child: Text(
                '通过 OpenJMU 扫一扫上方的二维码图案，加我为好友',
                style: context.textTheme.caption.copyWith(fontSize: 18.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return Tapper(
      onTap: saveToGallery,
      child: Container(
        height: 80.w,
        alignment: Alignment.center,
        child: Text(
          '保存图片',
          style: context.textTheme.bodyText2.copyWith(
            fontSize: 22.sp,
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
        children: <Widget>[
          Tapper(
            onTap: Navigator.of(context).pop,
            child: const SizedBox.expand(),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.w),
              child: Container(
                width: minWidth / 1.5,
                color: context.theme.colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _qrWidget(context),
                    Divider(thickness: 1.w, height: 1.w),
                    _saveButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
