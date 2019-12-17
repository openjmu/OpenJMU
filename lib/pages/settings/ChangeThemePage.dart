import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';

@FFRoute(
  name: "openjmu://theme",
  routeName: "更改主题",
)
class ChangeThemePage extends StatelessWidget {
  Widget colorItem(context, int index) {
    return Consumer<ThemesProvider>(
      builder: (_, provider, __) {
        return InkWell(
          onTap: () {
            provider.updateThemeColor(index);
          },
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(suSetWidth(12.0)),
                color: supportColors[index],
              ),
              AnimatedOpacity(
                duration: kTabScrollDuration,
                opacity:
                    provider.currentColor == supportColors[index] ? 1.0 : 0.0,
                child: Container(
                  margin: EdgeInsets.all(suSetWidth(12.0)),
                  color: const Color(0x66ffffff),
                  child: SizedBox.expand(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: suSetSp(40.0),
                    ),
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
            title: Text(
              '切换主题',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: suSetSp(23.0),
                  ),
            ),
            elevation: 0.0,
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: supportColors.length,
              itemBuilder: colorItem,
            ),
          ),
        ],
      ),
    );
  }
}
