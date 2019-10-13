import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Configs.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class FontScalePage extends StatefulWidget {
    @override
    _FontScalePageState createState() => _FontScalePageState();
}

class _FontScalePageState extends State<FontScalePage> {
    final List<double> scaleRange = Configs.scaleRange;
    double scale = Configs.fontScale;

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async{
                await DataUtils.setFontScale(scale);
                return true;
            },
            child: Scaffold(
                appBar: AppBar(
                    title: Text(
                        "调节字体大小",
                        style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: Constants.suSetSp(21.0),
                        ),
                    ),
                    centerTitle: true,
                ),
                body: Column(
                    children: <Widget>[
                        Expanded(
                            child: Center(
                                child: Text(
                                    "这是一行示例文字\nThis is a sample sentence",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Constants.suSetSp(20.0, scale: scale),
                                    ),
                                ),
                            ),
                        ),
                        BottomAppBar(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 20.0,
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                                Text(
                                                    "小",
                                                    style: TextStyle(
                                                        fontSize: Constants.suSetSp(18, scale: scaleRange[0]),
                                                    ),
                                                ),
                                                Text(
                                                    "标准",
                                                    style: TextStyle(
                                                        fontSize: Constants.suSetSp(
                                                            18,
                                                            scale: (scaleRange[0] + scaleRange[1]) / 2,
                                                        ),
                                                    ),
                                                ),
                                                Text(
                                                    "大",
                                                    style: TextStyle(
                                                        fontSize: Constants.suSetSp(18, scale: scaleRange[1]),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Slider(
                                        min: scaleRange[0],
                                        max: scaleRange[1],
                                        divisions: 4,
                                        activeColor: ThemeUtils.currentThemeColor,
                                        inactiveColor: ThemeUtils.currentThemeColor.withAlpha(50),
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
