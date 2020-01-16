import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/user/user_page.dart';

@FFRoute(
  name: "openjmu://scan-qrcode",
  routeName: "扫描二维码",
)
class ScanQrCodePage extends StatefulWidget {
  @override
  _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

  Widget backdrop({double width, double height, Widget child}) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Color(0x99000000),
        child: child ?? null,
      );

  Future onScan(context, String data) async {
    if (API.urlReg.stringMatch(data) != null) {
      Navigator.of(context).pushReplacement(platformPageRoute(
        context: context,
        builder: (_) => InAppBrowserPage(url: data),
      ));
    } else if (API.schemeUserPage.stringMatch(data) != null) {
      Navigator.of(context).pushReplacement(platformPageRoute(
        context: context,
        builder: (_) => UserPage(
          uid: int.parse(data.substring(API.schemeUserPage.pattern.length - 2)),
        ),
      ));
    } else {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("扫码结果"),
          content: Text(data),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("确认"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      _key.currentState.startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        title: Text(
          "扫描二维码",
          style: Theme.of(context).textTheme.title.copyWith(
                fontSize: suSetSp(21.0),
              ),
        ),
        centerTitle: true,
      ),
      body: QrcodeReaderView(
        key: _key,
        onScan: (String data) {
          return onScan(context, data);
        },
      ),
    );
  }
}
