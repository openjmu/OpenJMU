import 'package:OpenJMU/constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


class TestAnimatedWidgetPage extends StatefulWidget {
    @override
    _TestAnimatedWidgetPageState createState() => _TestAnimatedWidgetPageState();
}

class _TestAnimatedWidgetPageState extends State<TestAnimatedWidgetPage> {
    bool up = true;
    @override
    void initState() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
            print("Down.");
            up = false;
            if (mounted) setState(() {});
        });
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Test Animated Widget Page",
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                ),
                centerTitle: true,
            ),
            body: Column(
                children: <Widget>[
                    PanelItem(context, 0, onTap: () {}),
                ],
            ),
        );
    }
}

class PanelItem extends StatefulWidget {
    final BuildContext context;
    final int index;
    final GestureTapCallback onTap;

    const PanelItem(
        this.context,
        this.index, {
        Key key,
        this.onTap,
    }) : super(key: key);

    @override
    _PanelItemState createState() => _PanelItemState();
}

class _PanelItemState extends State<PanelItem> {
    bool _expanded = false;

    @override
    Widget build(BuildContext context) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                InkWell(
                    highlightColor: Colors.grey[300],
                    onTap: () {
                        _expanded = !_expanded;
                        print(_expanded);
                        widget.onTap();
                        if (mounted) setState(() {});
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                Text("测试条目"),
                                Icon(Icons.chevron_right),
                            ],
                        ),
                    ),
                ),
                AnimatedContainer(
                    color: Colors.teal,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text("Panel"),
                    ),
                    transform: Matrix4.diagonal3Values(1, _expanded ? 1 : 0, 1),
                )
            ],
        );
    }
}
