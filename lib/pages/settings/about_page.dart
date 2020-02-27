import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://about', routeName: '关于页')
class AboutPage extends StatelessWidget {
  List<Map<String, dynamic>> get actions => [
        {
          'name': '版本履历',
          'onTap': () {
            navigatorState.pushNamed(Routes.OPENJMU_CHANGELOG_PAGE);
          },
        },
        {
          'name': '官方网站',
          'onTap': () {
            API.launchWeb(url: API.homePage, title: 'OpenJMU');
          },
        },
        {
          'name': '吐个槽',
          'onTap': () {
            API.launchWeb(url: API.complaints, title: '吐个槽');
          },
        },
        if (Platform.isAndroid)
          {
            'name': '检查新版本',
            'onTap': () {
              PackageUtils.checkUpdate(fromHome: true);
            },
          }
      ];

  Future<void> showDebugInfoDialog(context) async {
    final info = '[uid      ] ${currentUser.uid}\n'
        '[sid      ] ${currentUser.sid}\n'
        '[ticket   ] ${currentUser.ticket}\n'
        '[workId   ] ${currentUser.workId}\n'
        '[uuid     ] ${DeviceUtils.deviceUuid}\n'
        '${DeviceUtils.devicePushToken != null ? '[pushToken] ${DeviceUtils.devicePushToken}\n' : ''}'
        '[model    ] ${DeviceUtils.deviceModel}';
    final list = info.split('\n');
    final copy = await ConfirmationDialog.show(
      context,
      title: '调试信息',
      showConfirm: true,
      confirmLabel: '复制',
      cancelLabel: '返回',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(list.length, (i) {
            return Text.rich(
              TextSpan(
                children: List<InlineSpan>.generate(list[i].length, (j) {
                  return WidgetSpan(
                    alignment: ui.PlaceholderAlignment.middle,
                    child: Text(
                      list[i].substring(j, j + 1),
                      style: TextStyle(
                        fontSize: suSetSp(16.0),
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  );
                }),
              ),
              textAlign: TextAlign.left,
            );
          }),
        ),
      ),
    );
    if (copy) {
      unawaited(Clipboard.setData(ClipboardData(text: info)));
      showToast('已复制到剪贴板');
    }
  }

  Widget logo(context) => GestureDetector(
        onDoubleTap: () => showDebugInfoDialog(context),
        child: Container(
          margin: EdgeInsets.only(bottom: suSetHeight(40.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(suSetWidth(20.0)),
            child: Image.asset(
              R.IMAGES_LOGO_1024_PNG,
              width: suSetWidth(100.0),
              height: suSetWidth(100.0),
            ),
          ),
        ),
      );

  Widget get appName => Container(
        margin: EdgeInsets.only(bottom: suSetHeight(10.0)),
        child: Text(
          'OpenJmu',
          style: TextStyle(
            fontFamily: 'chocolate',
            color: currentThemeColor,
            fontSize: suSetSp(50.0),
          ),
        ),
      );

  Widget get versionInfo => Container(
        margin: EdgeInsets.only(bottom: suSetHeight(10.0)),
        child: Text(
          'Version ${PackageUtils.version} (${PackageUtils.buildNumber})',
          style: TextStyle(fontSize: suSetSp(22.0)),
        ),
      );

  Widget actionList(context) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).canvasColor,
              width: suSetHeight(1.0),
            ),
          ),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: suSetWidth(20.0),
          vertical: suSetHeight(40.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: suSetWidth(30.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(actions.length * 2, (i) {
            if (i.isOdd) {
              return Divider(
                color: Theme.of(context).canvasColor,
                height: suSetHeight(1.0),
                thickness: suSetHeight(1.0),
              );
            } else {
              final index = i ~/ 2;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: actions[index]['onTap'],
                child: SizedBox(
                  height: suSetHeight(70.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${actions[index]['name']}',
                        style: TextStyle(fontSize: suSetSp(22.0)),
                      ),
                      Spacer(),
                      SvgPicture.asset(
                        R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                        color: Colors.grey,
                        width: suSetWidth(30.0),
                        height: suSetWidth(30.0),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
        ),
      );

  Widget agreement(context) => GestureDetector(
        onTap: () {
          API.launchWeb(url: '${API.homePage}/license.html', title: 'OpenJMU 用户协议');
        },
        child: Container(
          margin: EdgeInsets.only(bottom: suSetHeight(10.0)),
          child: Text(
            '《用户协议》',
            style: TextStyle(color: currentThemeColor, fontSize: suSetSp(18.0)),
          ),
        ),
      );

  Widget developedBy(context) => Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'Developed By '),
            TextSpan(
              text: 'OpenJmu Team',
              style: TextStyle(
                color: currentThemeColor,
                fontFamily: 'chocolate',
                fontSize: suSetSp(24.0),
              ),
            ),
          ],
        ),
        style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: suSetHeight(30.0)),
        child: Column(
          children: <Widget>[
            FixedAppBar(elevation: 0.0),
            Expanded(
              child: Column(
                children: <Widget>[
                  logo(context),
                  appName,
                  versionInfo,
                  actionList(context),
                  Spacer(),
                  agreement(context),
                  developedBy(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
