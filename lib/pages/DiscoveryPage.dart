import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/api/Api.dart';
//import 'package:OpenJMU/pages/SignDailyPage.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class DiscoveryPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => DiscoveryPageState();
}

class DiscoveryPageState extends State<DiscoveryPage> {
    int signedCount = 0;
    bool signing = false, signed = false;

    int userLevel = 0, userLevelExpCurrent = 0, userLevelExpUpBound = 0;
    int currentWeek;

    @override
    void initState() {
        super.initState();
        getSignStatus();
        getCurrentWeek();
    }

    Future<Null> getSignStatus() async {
        var _signed = jsonDecode(await SignAPI.getTodayStatus())['status'];
        var _signedCount = jsonDecode(await SignAPI.getSignList())['signdata']?.length;
        var _userTasks = jsonDecode(await NetUtils.getWithCookieSet(Api.task));
        setState(() {
            this.signedCount = _signedCount;
            this.signed = _signed == 1 ? true : false;
            this.userLevel = _userTasks['level'];
            this.userLevelExpCurrent = _userTasks['exp'];
            this.userLevelExpUpBound = _userTasks['exp_up'];
        });
    }

    Future<Null> getCurrentWeek() async {
        String _day = jsonDecode(await DateAPI.getCurrentWeek())['start'];
        DateTime startDate = DateTime.parse(_day);
        int difference = startDate.difference(DateTime.now()).inDays;
        if (difference < 0) {
            int week = (difference / 7).floor().abs();
            if (week <= 20) setState(() {
              this.currentWeek = week;
            });
        }
    }

    void requestSign() async {
        if (!signed) {
            setState(() {
                signing = true;
            });
            SignAPI.requestSign().then((response) {
                setState(() {
                    signed = true;
                    signing = false;
                    signedCount++;
                });
            }).catchError((e) {
                print(e.toString());
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        DateTime now = DateTime.now();
        return Container(
            padding: EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    RichText(text: TextSpan(
                        children: <TextSpan>[
                            if (currentWeek != null)TextSpan(text: "第$currentWeek周 "),
                            TextSpan(text: "${DateFormat("MMMdd日 ","zh_CN").format(now)}"),
                            TextSpan(text: "${DateFormat("EE","zh_CN").format(now)}"),
                        ],
                        style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.caption.color),
                    )),
                    Text(
                        "你好，${UserUtils.currentUser.name}",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 40, bottom: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Text("我的", style: TextStyle(fontSize: 20)),
                                Container(width: 34, height: 2, color: ThemeUtils.currentColorTheme),
                            ],
                        ),
                    ),
                    GridView(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 26,
                            mainAxisSpacing: 26,
                        ),
                        shrinkWrap: true,
                        children: <Widget>[
                            GridItem(
                                onTap: requestSign,
                                children: <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                            Icon(Icons.person_pin, size: 32, color: ThemeUtils.currentColorTheme),
                                        ],
                                    ),
                                    Expanded(child: Container()),
                                    RichText(text: TextSpan(
                                        children: <TextSpan>[
                                            TextSpan(text: "Lv.", style: TextStyle(fontSize: 30.0)),
                                            TextSpan(text: "$userLevel", style: TextStyle(fontSize: 64.0, fontWeight: FontWeight.bold))
                                        ],
                                    )),
                                    Text("$userLevelExpCurrent/$userLevelExpUpBound", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                    )),
                                ],
                            ),
                            GridItem(
                                onTap: requestSign,
                                children: <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                            Icon(Icons.place, size: 32, color: ThemeUtils.currentColorTheme),
                                            !signed ? !signing
                                                    ? Icon(Icons.arrow_forward, color: Colors.white)
                                                    : SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    strokeWidth: 3,
                                                ),
                                            )
                                                    : Icon(Icons.check_circle_outline, color: Colors.white),
                                        ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(signed ? "已签到" : "未签到", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                    )),
                                    Text("本月已签$signedCount天", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                    )),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}

class GridItem extends StatefulWidget {
    final List<Widget> children;
    final Function onTap;

    GridItem({@required this.children, @required this.onTap, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {

    @override
    Widget build(BuildContext context) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
                color: ThemeUtils.currentColorTheme,
                child: CustomPaint(
                    painter: IconPainter(context),
                    child: InkWell(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.children,
                            ),
                        ),
                        onTap: widget.onTap,
                    ),
                ),
            ),
        );
    }
}

class IconPainter extends CustomPainter {
    final BuildContext context;

    IconPainter(this.context);

    @override
    void paint(Canvas canvas, Size size) {
        List<Color> colorPairing = List(2);
        colorPairing[0] = Color(0xccffffff);
        colorPairing[1] = Color(0x88ffffff);

        Paint paint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = colorPairing[0];
        canvas.drawCircle(Offset(26, 26), size.width / 6.6, paint);
        paint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = colorPairing[1];
        canvas.drawCircle(Offset(26, 26), size.width / 5, paint);
        paint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = colorPairing[1];
        canvas.drawCircle(Offset(26, 26), size.width / 4.2, paint);
    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) => true;
}
