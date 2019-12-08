import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';

@FFRoute(
  name: "openjmu://theme",
  routeName: "更改主题",
)
class ChangeThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangeThemePageState();
}

class ChangeThemePageState extends State<ChangeThemePage> {
  List<Color> colors = ThemeUtils.supportColors;
  Color currentColor = ThemeUtils.currentThemeColor;
  int selected;

  @override
  void initState() {
    selected = DataUtils.getColorThemeIndex();
    Instances.eventBus
      ..on<ChangeThemeEvent>().listen((event) {
        ThemeUtils.currentThemeColor = event.color;
        currentColor = event.color;
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  void changeColorTheme(Color color) {
    Instances.eventBus.fire(ChangeThemeEvent(color));
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
          ),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 4,
              children: List.generate(colors.length, (index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selected = index;
                    });
                    DataUtils.setColorTheme(index);
                    changeColorTheme(colors[index]);
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: colors[index],
                        margin: EdgeInsets.all(suSetSp(10.0)),
                      ),
                      if (selected == index)
                        Container(
                          color: const Color(0x66ffffff),
                          margin: EdgeInsets.all(suSetSp(10.0)),
                          child: Icon(Icons.check,
                              color: Colors.white, size: suSetSp(40.0)),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
