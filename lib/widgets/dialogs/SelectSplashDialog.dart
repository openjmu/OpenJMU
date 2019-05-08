import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class SelectSplashDialog extends StatefulWidget {
  @override
  _SelectSplashDialogState createState() => _SelectSplashDialogState();
}

class _SelectSplashDialogState extends State<SelectSplashDialog> {
  final List<String> pagesTitle = ["首页", "应用", "发现"];
  int tabIndex = Constants.homeSplashIndex;

  final BoxDecoration activePageShadow = BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
            blurRadius: 10.0,
            color: ThemeUtils.currentColorTheme
        )
      ]
  );

  Widget pageSelector(int index, double width) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          tabIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            decoration: tabIndex == index ? activePageShadow : null,
            child: Image.asset(
              "assets/homeSplash/$index.jpg",
              width: width,
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 16.0),
              width: width,
              child: Center(child: Text(pagesTitle[index], style: TextStyle(fontSize: 16.0)))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = (MediaQuery.of(context).size.width - 130) / 3;
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 60,
            color: Theme.of(context).canvasColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("更改默认启动页", style: Theme.of(context).textTheme.title),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        pageSelector(0, _width),
                        pageSelector(1, _width),
                        pageSelector(2, _width)
                      ]
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Divider(height: 1)
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        child: Text("取消", style: TextStyle(
                            color: ThemeUtils.currentColorTheme,
                            fontSize: 18.0)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        child: Text("保存", style: TextStyle(
                            color: Theme.of(context).textTheme.body1.color,
                            fontSize: 18.0)
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          DataUtils.setHomeSplashIndex(tabIndex);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
      ),
    );
  }
}
