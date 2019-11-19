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

class _AddingButtonPageState extends State<AddingButtonPage>
    with TickerProviderStateMixin {
  final List<String> itemTitles = [
    "动态",
    "扫一扫",
    "集市",
  ];
  final List<String> itemIcons = [
    "subscriptedAccount",
    "scan",
    "scan",
  ];
  final List<Color> itemColors = [
    Colors.orange,
    Colors.teal,
    Colors.indigoAccent,
  ];
  final List<Function> itemOnTap = [
    (context) async {
      currentState.pushNamed("openjmu://publish-post");
    },
    (context) async {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([
        PermissionGroup.camera,
      ]);
      if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
        currentState.pushNamed("openjmu://scan-qrcode");
      }
    },
    (context) async {
      currentState.pushNamed("openjmu://publish-team-post");
    },
  ];

  /// Animation.
  /// Boolean to prevent duplicate pop.
  bool popping = false;
  final int _animateDuration = 300;
  double _backdropFilterSize = 0.0;
  double _popButtonOpacity = 0.01;
  double _popButtonRotateAngle = 0.0;
  Animation<double> _backDropFilterAnimation;
  AnimationController _backDropFilterController;
  Animation<double> _popButtonAnimation;
  AnimationController _popButtonController;
  Animation<double> _popButtonOpacityAnimation;
  AnimationController _popButtonOpacityController;
  List<double> _itemOffset;
  List<Animation<double>> _itemAnimations;
  List<CurvedAnimation> _itemCurveAnimations;
  List<AnimationController> _itemAnimateControllers;
  List<double> _itemOpacity;
  List<Animation<double>> _itemOpacityAnimations;
  List<CurvedAnimation> _itemOpacityCurveAnimations;
  List<AnimationController> _itemOpacityAnimateControllers;

  @override
  void initState() {
    initItemsAnimation();
    SchedulerBinding.instance
        .addPostFrameCallback((_) => backDropFilterAnimate(context, true));
    super.initState();
  }

  @override
  void dispose() {
    _backDropFilterController?.dispose();
    _popButtonController?.dispose();
    _itemAnimateControllers?.forEach((controller) {
      controller?.dispose();
    });
    _itemOpacityAnimateControllers?.forEach((controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  void initItemsAnimation() {
    _itemOffset = <double>[for (int i = 0; i < itemTitles.length; i++) 0.0];
    _itemAnimations = List(itemTitles.length);
    _itemCurveAnimations = List(itemTitles.length);
    _itemAnimateControllers = List(itemTitles.length);
    _itemOpacity = <double>[for (int i = 0; i < itemTitles.length; i++) 0.01];
    _itemOpacityAnimations = List(itemTitles.length);
    _itemOpacityCurveAnimations = List(itemTitles.length);
    _itemOpacityAnimateControllers = List(itemTitles.length);

    for (int i = 0; i < itemTitles.length; i++) {
      _itemAnimateControllers[i] = AnimationController(
        duration: Duration(milliseconds: _animateDuration),
        vsync: this,
      );
      _itemCurveAnimations[i] = CurvedAnimation(
        parent: _itemAnimateControllers[i],
        curve: Curves.ease,
      );
      _itemAnimations[i] = Tween(
        begin: -20.0,
        end: 0.0,
      ).animate(_itemCurveAnimations[i])
        ..addListener(() {
          setState(() {
            _itemOffset[i] = _itemAnimations[i].value;
          });
        });

      _itemOpacityAnimateControllers[i] = AnimationController(
        duration: Duration(milliseconds: _animateDuration),
        vsync: this,
      );
      _itemOpacityCurveAnimations[i] = CurvedAnimation(
        parent: _itemOpacityAnimateControllers[i],
        curve: Curves.linear,
      );
      _itemOpacityAnimations[i] = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(_itemOpacityCurveAnimations[i])
        ..addListener(() {
          setState(() {
            _itemOpacity[i] = _itemOpacityAnimations[i].value;
          });
        });
    }
  }

  void itemsAnimate(bool forward) {
    for (int i = 0; i < _itemAnimateControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (forward) {
          _itemAnimateControllers[i]?.forward();
          _itemOpacityAnimateControllers[i]?.forward();
        } else {
          _itemAnimateControllers[i]?.reverse();
          _itemOpacityAnimateControllers[i]?.reverse();
        }
      });
    }
  }

  void popButtonAnimate(context, bool forward) {
    if (!forward) {
      _popButtonController?.stop();
      _popButtonOpacityController?.stop();
    }
    final rotateDegree = 45 * (math.pi / 180) * 3;

    _popButtonOpacityController = _popButtonController = AnimationController(
      duration: Duration(milliseconds: _animateDuration),
      vsync: this,
    );
    Animation _popButtonCurve = CurvedAnimation(
      parent: _popButtonController,
      curve: Curves.easeInOut,
    );
    _popButtonAnimation = Tween(
      begin: forward ? 0.0 : _popButtonRotateAngle,
      end: forward ? rotateDegree : 0.0,
    ).animate(_popButtonCurve)
      ..addListener(() {
        setState(() {
          _popButtonRotateAngle = _popButtonAnimation.value;
        });
      });
    _popButtonOpacityAnimation = Tween(
      begin: forward ? 0.01 : _popButtonOpacity,
      end: forward ? 1.0 : 0.01,
    ).animate(_popButtonCurve)
      ..addListener(() {
        setState(() {
          _popButtonOpacity = _popButtonOpacityAnimation.value;
        });
      });
    _popButtonController.forward();
    _popButtonOpacityController.forward();
  }

  Future backDropFilterAnimate(BuildContext context, bool forward) async {
    final double r = pythagoreanTheorem(
            Screen.width, Screen.height * 2 + Screen.topSafeHeight) /
        2;
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
      begin: forward ? 0.0 : _backdropFilterSize,
      end: forward ? r * 2 : 0.0,
    ).animate(_backDropFilterCurve)
      ..addListener(() {
        setState(() {
          _backdropFilterSize = _backDropFilterAnimation.value;
        });
      });
    if (forward) {
      Future.delayed(
        Duration(milliseconds: _animateDuration ~/ 2),
        () {
          itemsAnimate(true);
        },
      );
    } else {
      itemsAnimate(false);
    }
    await _backDropFilterController.forward();
  }

  double pythagoreanTheorem(double short, double long) {
    return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
  }

  Widget popButton() {
    return Opacity(
      opacity: _popButtonOpacity,
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: suSetSp(MainPageState.bottomBarHeight),
            height: suSetSp(MainPageState.bottomBarHeight),
            child: Transform.rotate(
              angle: _popButtonRotateAngle,
              child: Icon(
                Icons.add,
                color: Colors.grey,
                size: suSetWidth(48.0),
              ),
            ),
          ),
          onTap: willPop,
        ),
      ),
    );
  }

  Widget wrapper(context, {Widget child}) {
    final double r = pythagoreanTheorem(
            Screen.width,
            Screen.height * 2 +
                Screen.topSafeHeight +
                Screen.bottomSafeHeight) /
        2;
    final double topOverflow = r - Screen.height;
    final double horizontalOverflow = r - Screen.width;

    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          left: -horizontalOverflow,
          right: -horizontalOverflow,
          top: -topOverflow,
          bottom: -r,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: willPop,
            child: Center(
              child: SizedBox(
                width: _backdropFilterSize,
                height: _backdropFilterSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r * 2),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Text(" "),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: topOverflow),
            width: Screen.width,
            height: Screen.height,
            constraints: BoxConstraints(
              maxWidth: Screen.width,
              maxHeight: Screen.height,
            ),
            child: child ?? SizedBox(),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: Screen.bottomSafeHeight,
          child: popButton(),
        ),
      ],
    );
  }

  Widget item(BuildContext context, int index) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          left: 0.0,
          right: 0.0,
          top: _itemOffset[index],
          child: Opacity(
            opacity: _itemOpacity[index],
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(suSetSp(16.0)),
                    decoration: BoxDecoration(
                      color: itemColors[index],
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/${itemIcons[index]}-line.svg",
                      color: Colors.white,
                      width: suSetSp(28.0),
                      height: suSetSp(28.0),
                    ),
                  ),
                  Constants.emptyDivider(height: 10.0),
                  Text(
                    itemTitles[index],
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: suSetSp(18.0),
                        ),
                  ),
                ],
              ),
              onTap: () {
                itemOnTap[index](context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> willPop() async {
    await backDropFilterAnimate(context, false);
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
      child: wrapper(
        context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: <Widget>[
                for (int i = 0; i < itemTitles.length; i++) item(context, i),
              ],
            ),
            SizedBox(height: suSetHeight(120.0)),
          ],
        ),
      ),
    );
  }
}
