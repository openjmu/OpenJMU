import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

@FFRoute(
  name: "openjmu://about",
  routeName: "关于页",
)
class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int tries = 0;
  String currentVersion;

  @override
  void initState() {
    super.initState();
    OTAUtils.getCurrentVersion().then((version) {
      setState(() {
        currentVersion = version;
      });
    });
  }

  void tryDisplayDebugInfo() {
    tries++;
    if (tries == 10) setState(() {});
  }

  Widget about() {
    return Container(
      padding: EdgeInsets.all(suSetSp(20.0)),
      child: Center(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: tries < 10 ? tryDisplayDebugInfo : null,
              child: Container(
                margin: EdgeInsets.only(bottom: suSetSp(20.0)),
                child: SvgPicture.asset(
                  "images/splash_page_logo.svg",
                  width: suSetSp(180.0),
                  height: suSetSp(180.0),
                  color: ThemeUtils.defaultColor,
                ),
              ),
            ),
            SizedBox(height: suSetSp(30.0)),
            Container(
              margin: EdgeInsets.only(bottom: suSetSp(12.0)),
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: "OpenJmu",
                  style: TextStyle(
                    fontFamily: 'chocolate',
                    color: ThemeUtils.currentThemeColor,
                    fontSize: suSetSp(50.0),
                  ),
                ),
                TextSpan(
                    text: "　v$currentVersion",
                    style: Theme.of(context).textTheme.subtitle),
              ])),
            ),
            SizedBox(height: suSetSp(20.0)),
            RichText(
                text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "Developed By ",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.body1.color,
                  ),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => CommonWebPage.jump(API.homePage, "OpenJMU"),
                  text: "OpenJMU Team",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontFamily: 'chocolate',
                    fontSize: suSetSp(24.0),
                  ),
                ),
                TextSpan(
                    text: " .",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.body1.color)),
              ],
            )),
            SizedBox(height: suSetSp(80.0)),
          ],
        ),
      ),
    );
  }

  Widget debugInfo() {
    final user = UserAPI.currentUser;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SelectableText(
          "———— START DEBUG INFO ————\n"
          "uid: ${user.uid}\n"
          "sid: ${user.sid}\n"
          "workId: ${user.workId}\n"
          "blowfish: ${user.blowfish}\n"
          "————— END DEBUG INFO —————\n",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "关于OpenJMU",
          style: Theme.of(context).textTheme.title.copyWith(
                fontSize: suSetSp(21.0),
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              about(),
              tries == 10 ? debugInfo() : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
