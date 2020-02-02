import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://theme", routeName: "更改主题")
class ChangeThemePage extends StatelessWidget {
  Widget colorItem(context, int index) {
    return Consumer<ThemesProvider>(
      builder: (_, provider, __) {
        return InkWell(
          onTap: () => provider.updateThemeColor(index),
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(suSetWidth(12.0)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                  color: supportColors[index],
                ),
              ),
              AnimatedOpacity(
                duration: 100.milliseconds,
                opacity: provider.currentColor == supportColors[index] ? 1.0 : 0.0,
                child: Container(
                  margin: EdgeInsets.all(suSetWidth(12.0)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                    color: Colors.white38,
                  ),
                  child: SizedBox.expand(
                    child: Icon(Icons.check, color: Colors.white, size: suSetSp(40.0)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '切换主题',
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: suSetSp(26.0),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '多彩颜色，丰富你的界面',
                  style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(18.0)),
                ),
              ],
            ),
            elevation: 0.0,
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: supportColors.length,
              itemBuilder: colorItem,
            ),
          ),
        ],
      ),
    );
  }
}
