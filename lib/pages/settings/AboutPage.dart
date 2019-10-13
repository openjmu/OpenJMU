import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatefulWidget {
    @override
    _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

    Widget about() {
        return Container(
            padding: EdgeInsets.all(Constants.suSetSp(20.0)),
            child: Center(
                child: Column(
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: Constants.suSetSp(20.0)),
                            child: SvgPicture.asset(
                                "images/splash_page_logo.svg",
                                width: Constants.suSetSp(180.0),
                                height: Constants.suSetSp(180.0),
                                color: ThemeUtils.defaultColor,
                            ),
                        ),
                        SizedBox(height: Constants.suSetSp(30.0)),
                        Container(
                            margin: EdgeInsets.only(bottom: Constants.suSetSp(12.0)),
                            child: RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: "OpenJmu",
                                    style: TextStyle(
                                        fontFamily: 'chocolate',
                                        color: ThemeUtils.currentThemeColor,
                                        fontSize: Constants.suSetSp(50.0),
                                    ),
                                ),
                                TextSpan(text: "　v$currentVersion", style: Theme.of(context).textTheme.subtitle),
                            ])),
                        ),
                        SizedBox(height: Constants.suSetSp(20.0)),
                        RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: "Developed By ",
                                    style: TextStyle(
                                        color: Theme.of(context).textTheme.body1.color,
                                    ),
                                ),
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                            return CommonWebPage.jump(context, API.homePage, "OpenJMU");
                                        },
                                    text: "OpenJMU Team",
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontFamily: 'chocolate',
                                        fontSize: Constants.suSetSp(24.0),
                                    ),
                                ),
                                TextSpan(text: " .", style: TextStyle(color: Theme.of(context).textTheme.body1.color)),
                            ],
                        )),
                        SizedBox(height: Constants.suSetSp(80.0)),
                    ],
                ),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "关于OpenJMU",
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                ),
                centerTitle: true,
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    about(),
                    SizedBox(height: Constants.suSetSp(100.0))
                ],
            )
        );
    }
}
