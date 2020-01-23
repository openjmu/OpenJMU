import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/appbar.dart';

@FFRoute(
  name: "openjmu://font-scale",
  routeName: "更改字号页",
)
class FontScalePage extends StatefulWidget {
  @override
  _FontScalePageState createState() => _FontScalePageState();
}

class _FontScalePageState extends State<FontScalePage> {
  final baseFontSize = 24.0;
  SettingsProvider settingsProvider;

  List<double> scaleRange;
  double scale;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(currentContext, listen: false);
    scaleRange = settingsProvider.fontScaleRange;
    scale = settingsProvider.fontScale;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await HiveFieldUtils.setFontScale(scale);
        return true;
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            FixedAppBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "字体大小调节",
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontSize: suSetSp(26.0),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    "调整字体大小以获得最佳阅读体验",
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: suSetSp(18.0),
                        ),
                  ),
                ],
              ),
              elevation: 0.0,
            ),
            Expanded(
              child: Center(
                child: Text(
                  "这是一行示例文字\nThis is a sample sentence",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: suSetSp(baseFontSize, scale: scale)),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "小",
                              style: TextStyle(
                                fontSize: suSetSp(baseFontSize, scale: scaleRange[0]),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "标准",
                              style: TextStyle(
                                fontSize: suSetSp(
                                  baseFontSize,
                                  scale: (scaleRange[0] + scaleRange[1]) / 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "大",
                              style: TextStyle(
                                fontSize: suSetSp(baseFontSize, scale: scaleRange[1]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    min: scaleRange[0],
                    max: scaleRange[1],
                    divisions: 8,
                    activeColor: currentThemeColor,
                    inactiveColor: currentThemeColor.withAlpha(50),
                    value: scale,
                    onChanged: (double value) {
                      setState(() {
                        scale = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
