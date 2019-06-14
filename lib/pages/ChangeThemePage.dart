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
    Color currentColor = ThemeUtils.currentThemeColor;
    int selected;

    @override
    void initState() {
        super.initState();
        DataUtils.getColorThemeIndex().then((index) {
            if (this.mounted) setState(() { this.selected = index; });
        });
        Constants.eventBus..on<ChangeThemeEvent>().listen((event) {
            if (this.mounted) setState(() {
                ThemeUtils.currentThemeColor = event.color;
                currentColor = event.color;
            });
        });
    }

    void changeColorTheme(Color color) {
        Constants.eventBus.fire(new ChangeThemeEvent(color));
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    '切换主题',
                    style: Theme.of(context).textTheme.title,
                ),
                centerTitle: true,
            ),
            body: Container(
                child: GridView.count(
                    crossAxisCount: 4,
                    children: List.generate(colors.length, (index) {
                        return InkWell(
                            onTap: () {
                                setState(() { this.selected = index; });
                                DataUtils.setColorTheme(index);
                                changeColorTheme(colors[index]);
                            },
                            child: Stack(
                                children: <Widget>[
                                    Container(
                                        color: colors[index],
                                        margin: EdgeInsets.all(Constants.suSetSp(10.0)),
                                    ),
                                    if (this.selected == index) Container(
                                        color: const Color(0x66ffffff),
                                        margin: EdgeInsets.all(Constants.suSetSp(10.0)),
                                        child: Icon(Icons.check, color: Colors.white, size: Constants.suSetSp(40.0)),
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                    ),
                                ],
                            ),
                        );
                    }),
                ),
            ),
        );
    }
}
