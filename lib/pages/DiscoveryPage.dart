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

class SignAPI {
  static Future requestSign() async => NetUtils.postWithCookieAndHeaderSet(Api.sign);
  static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
      Api.signList,
      data: {"signmonth": "${new DateFormat("yyyy-MM").format(new DateTime.now())}"}
  );
  static Future getTodayStatus() async => NetUtils.postWithCookieAndHeaderSet(Api.signStatus);
  static Future getSignSummary() async => NetUtils.postWithCookieAndHeaderSet(Api.signSummary);
}

class DiscoveryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new DiscoveryPageState();
  }
}

class DiscoveryPageState extends State<DiscoveryPage> {
  int signedCount = 0;
  bool signing = false, signed = false;

  @override
  void initState() {
    super.initState();
    getSignStatus();
  }

  Future<Null> getSignStatus() async {
    var _signed = jsonDecode(await SignAPI.getTodayStatus())['status'];
    var _signedCount = jsonDecode(await SignAPI.getSignList())['signdata']?.length;
    setState(() {
      this.signedCount = _signedCount;
      this.signed = _signed == 1 ? true : false;
    });
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
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              new DateFormat("dd, MMMM, EE", "zh_CN").format(new DateTime.now()),
              style: TextStyle(fontSize: 28.0, color: Theme.of(context).textTheme.caption.color)
          ),
          Text(
              "你好，${UserUtils.currentUser.name}",
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)
          ),
          Container(
              margin: EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("今日任务", style: TextStyle(
                      fontSize: 18
                  )),
                  Container(width: 62, height: 2, color: ThemeUtils.currentColorTheme)
                ],
              )
          ),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 26,
                mainAxisSpacing: 26
            ),
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                    color: ThemeUtils.currentColorTheme,
                    child: CustomPaint(
                        painter: IconPainter(),
                        child: InkWell(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Icon(Icons.location_on, size: 32, color: ThemeUtils.currentColorTheme),
                                      !signed ? !signing
                                          ? Icon(Icons.arrow_forward, color: Colors.white)
                                          : SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 3,
                                            )
                                          )
                                        : Container()
                                    ]
                                ),
                                Expanded(child: Container()),
                                Text(signed ? "已签到" : "未签到", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold
                                )),
                                Text("本月已签$signedCount天", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0
                                )),
                              ],
                            ),
                          ),
                          onTap: requestSign
                        )
                    )
                )
            ),
          )
        ],
      ),
    );
  }

}

class IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0xccffffff);
    canvas.drawCircle(Offset(24, 24), size.width / 5, paint);

    paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0x99ffffff);
    canvas.drawCircle(Offset(24, 24), size.width / 4, paint);
    paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0x99ffffff);
    canvas.drawCircle(Offset(24, 24), size.width / 3.4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
