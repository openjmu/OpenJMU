import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';


class ScanQrCodePage extends StatefulWidget {
    @override
    _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
    GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

    @override
    void initState() {
        super.initState();
        ThemeUtils.setDark(true);
    }

    @override
    void dispose() {
        super.dispose();
        ThemeUtils.setDark(ThemeUtils.isDark);
    }

    Widget backdrop({double width, double height, Widget child}) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Color(0x99000000),
        child: child ?? null,
    );

    Future onScan(String data) async {
        if (Api.urlReg.stringMatch(data) != null) {
            Navigator.of(context).pushReplacement(platformPageRoute(
                builder: (_) => CommonWebPage(url: data, title: ""),
            ));
        } else if (Api.schemeUserPage.stringMatch(data) != null) {
            Navigator.of(context).pushReplacement(platformPageRoute(
                builder: (_) => UserPage(uid: int.parse(data.substring(Api.schemeUserPage.pattern.length - 2))),
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
                backgroundColor: Colors.transparent,
                title: Text("扫描二维码", style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: Constants.suSetSp(21.0),
                )),
                centerTitle: true,
            ),
            body: QrcodeReaderView(key: _key, onScan: onScan),
        );
    }
}
