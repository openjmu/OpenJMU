import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';


class AddingButtonPage extends StatefulWidget {
    @override
    _AddingButtonPageState createState() => _AddingButtonPageState();
}

class _AddingButtonPageState extends State<AddingButtonPage> with TickerProviderStateMixin {
    /// Boolean to prevent duplicate pop.
    bool popping = false;

    /// Animation.
    int _animateDuration = 300;
    double backgroundSize = 0.0;
    double buttonRotateAngle = 0.0;
    Animation<double> _backDropFilterAnimation;
    AnimationController _backDropFilterController;
    Animation<double> _popButtonAnimation;
    AnimationController _popButtonController;

    List<Color> buttonColors = [Colors.orange, Colors.teal];
    List<String> buttonIcons = ["subscriptedAccount", "scan"];
    List<String> buttonTitles = ["动态", "扫一扫"];
    List<Function> buttonVoids = [
        (context) { Navigator.of(context).pushNamed("/publishPost"); },
        (context) async {
            Map<PermissionGroup, PermissionStatus>permissions = await PermissionHandler().requestPermissions([
                PermissionGroup.camera,
            ]);
            if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
                Navigator.of(context).pushNamed("/scanqrcode");
            }
        },
    ];

    @override
    void initState() {
        SchedulerBinding.instance.addPostFrameCallback((_) => backDropFilterAnimate(context, true));
        super.initState();
    }

    @override
    void dispose() {
        _backDropFilterController?.dispose();
        super.dispose();
    }

    void popButtonAnimate(context, bool forward) {
        if (!forward) _popButtonController?.stop();
        final rotateDegree = 45 * (math.pi / 180) * 3;

        _popButtonController = AnimationController(
            duration: Duration(milliseconds: _animateDuration),
            vsync: this,
        );
        Animation _popButtonCurve = CurvedAnimation(
            parent: _popButtonController,
            curve: Curves.linear,
        );
        _popButtonAnimation = Tween(
            begin: forward ? 0.0 : buttonRotateAngle,
            end: forward ? rotateDegree : 0.0,
        ).animate(_popButtonCurve)
            ..addListener(() {
                setState(() {
                    buttonRotateAngle = _popButtonAnimation.value;
                });
            });
        _popButtonController.forward();
    }

    void backDropFilterAnimate(BuildContext context, bool forward) {
        if (!forward) _backDropFilterController?.stop();
        popButtonAnimate(context, forward);

        _backDropFilterController = AnimationController(
            duration: Duration(milliseconds: _animateDuration),
            vsync: this,
        );
        Animation _backDropFilterCurve = CurvedAnimation(
            parent: _backDropFilterController,
            curve: forward ? Curves.easeInOut : Curves.easeIn,
        );
        _backDropFilterAnimation = Tween(
            begin: forward ? 0.0 : backgroundSize,
            end: forward ? pythagoreanTheorem(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
            ) * 2 : 0.0,
        ).animate(_backDropFilterCurve)
            ..addListener(() {
                setState(() {
                    backgroundSize = _backDropFilterAnimation.value;
                });
            });
        _backDropFilterController.forward();
    }

    double pythagoreanTheorem(double short, double long) {
        return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
    }

    Widget popButton() {
        return Center(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                    width: MainPageState.bottomBarHeight,
                    height: MainPageState.bottomBarHeight,
                    child: Transform.rotate(
                        angle: buttonRotateAngle,
                        child: Icon(
                            Icons.add,
                            color: Colors.grey,
                            size: Constants.suSetSp(28.0),
                        ),
                    ),
                ),
                onTap: willPop,
            ),
        );
    }

    Widget wrapper(context, {Widget child}) {
        final Size s = MediaQuery.of(context).size;
        final double topOverflow = pythagoreanTheorem(s.width, s.height) - s.height;
        final double horizontalOverflow = (s.height - s.width);

        return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
                Positioned(
                    left: - horizontalOverflow,
                    right: - horizontalOverflow,
                    top: - topOverflow,
                    bottom: - pythagoreanTheorem(s.width, s.height),
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: willPop,
                        child: Center(
                            child: SizedBox(
                                width: backgroundSize,
                                height: backgroundSize,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(s.height * 2),
                                    child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                                        child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                                margin: EdgeInsets.only(top: topOverflow),
                                                width: s.width,
                                                height: s.height,
                                                constraints: BoxConstraints(
                                                    maxWidth: s.width,
                                                    maxHeight: s.height,
                                                ),
                                                child: child ?? SizedBox(),
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
                Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: popButton(),
                ),
            ],
        );
    }

    Widget item(BuildContext context, int index) {
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(Constants.suSetSp(16.0)),
                        decoration: BoxDecoration(
                            color: buttonColors[index],
                            shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                            "assets/icons/${buttonIcons[index]}-line.svg",
                            color: Colors.white,
                            width: Constants.suSetSp(28.0),
                            height: Constants.suSetSp(28.0),
                        ),
                    ),
                    Constants.emptyDivider(height: 10.0),
                    Text(
                        buttonTitles[index],
                        style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: Constants.suSetSp(18.0),
                        ),
                    ),
                ],
            ),
            onTap: () {
                buttonVoids[index](context);
            },
        );
    }

    Future<bool> willPop() async {
        backDropFilterAnimate(context, false);
        if (!popping) {
            popping = true;
            await Future.delayed(Duration(milliseconds: _animateDuration), () {
                Navigator.of(context).pop();
            });
        }
        return null;
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: willPop,
            child: wrapper(context, child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        children: <Widget>[
                            for (int i = 0; i < buttonTitles.length; i++)
                                item(context, i),
                        ],
                    ),
                    Constants.emptyDivider(height: 100.0),
                ],
            )),
        );
    }
}

