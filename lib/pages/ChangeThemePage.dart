import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class ChangeThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangeThemePageState();
}

class ChangeThemePageState extends State<ChangeThemePage> {
  List<Color> colors = ThemeUtils.supportColors;
  Color currentColor = ThemeUtils.currentColorTheme;

  @override
  void initState() {
    super.initState();
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          ThemeUtils.currentColorTheme = event.color;
          currentColor = event.color;
        });
      }
    });
  }

  void changeColorTheme(Color c) {
    Constants.eventBus.fire(new ChangeThemeEvent(c));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: currentColor,
          title: new Text(
              '切换主题',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.title.fontSize
              )
          ),
          centerTitle: true,
          brightness: Brightness.dark,
        ),
        body: new Padding(
            padding: EdgeInsets.all(8.0),
            child: new GridView.count(
              crossAxisCount: 4,
              children: new List.generate(colors.length, (index) {
                return new InkWell(
                  onTap: () {
                    DataUtils.setColorTheme(index);
                    changeColorTheme(colors[index]);
                  },
                  child: new Container(
                    color: colors[index],
                    margin: const EdgeInsets.all(5.0),
                  ),
                );
              }),
            )
        )
    );
  }

}