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
  final List<double> scaleRange = Configs.fontScaleRange;
  double scale = Configs.fontScale;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await DataUtils.setFontScale(scale);
        return true;
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            FixedAppBar(
              title: Text(
                "调节字体大小",
                style: Theme.of(context).textTheme.title.copyWith(
                      fontSize: suSetSp(23.0),
                    ),
              ),
              elevation: 0.0,
            ),
            Expanded(
              child: Center(
                child: Text(
                  "这是一行示例文字\nThis is a sample sentence",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: suSetSp(baseFontSize, scale: scale),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "小",
                              style: TextStyle(
                                fontSize: suSetSp(
                                  baseFontSize,
                                  scale: scaleRange[0],
                                ),
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
                                fontSize: suSetSp(
                                  baseFontSize,
                                  scale: scaleRange[1],
                                ),
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
