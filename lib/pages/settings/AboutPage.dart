import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';
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
                  width: suSetWidth(200.0),
                  height: suSetWidth(200.0),
                  color: defaultColor,
                ),
              ),
            ),
            SizedBox(height: suSetHeight(30.0)),
            Container(
              margin: EdgeInsets.only(bottom: suSetSp(12.0)),
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: "OpenJmu",
                  style: TextStyle(
                    fontFamily: 'chocolate',
                    color: currentThemeColor,
                    fontSize: suSetSp(50.0),
                  ),
                ),
                TextSpan(
                    text: "　v$currentVersion",
                    style: Theme.of(context).textTheme.subtitle),
              ])),
            ),
            SizedBox(height: suSetHeight(20.0)),
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
            SizedBox(height: suSetHeight(80.0)),
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
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Text(
              "关于OpenJMU",
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: suSetSp(23.0),
                  ),
            ),
            elevation: 0.0,
          ),
          Expanded(
            child: Center(
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
          ),
        ],
      ),
    );
  }
}
