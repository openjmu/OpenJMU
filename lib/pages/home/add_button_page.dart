import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';

class AddingButtonPage extends StatefulWidget {
  @override
  _AddingButtonPageState createState() => _AddingButtonPageState();
}

class _AddingButtonPageState extends State<AddingButtonPage> with TickerProviderStateMixin {
  final List<String> itemTitles = ["广场", "集市"];
  final List<Color> itemColors = [Colors.orange, Colors.indigoAccent];
  final List<Function> itemOnTap = [
    (context) async {
      navigatorState.pushNamed(Routes.OPENJMU_PUBLISH_POST);
    },
    (context) async {
      navigatorState.pushNamed(Routes.OPENJMU_PUBLISH_TEAM_POST);
    },
  ];
  final int _animateDuration = 300;
  double get backdropRadius =>
      pythagoreanTheorem(
        Screens.width,
        Screens.height * 2 + Screens.topSafeHeight + Screens.bottomSafeHeight,
      ) /
      2;

  /// Animation.
  /// Boolean to prevent duplicate pop.
  bool entering = true;
  bool popping = false;
  double _backgroundOpacity = 0.0;
  double _backdropFilterSize = 0.0;
  double _popButtonOpacity = 0.01;
  double _popButtonRotateAngle = 0.0;
  Animation<double> _backgroundOpacityAnimation;
  AnimationController _backgroundOpacityController;
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
    SchedulerBinding.instance.addPostFrameCallback((_) => backDropFilterAnimate(context, true));
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
    if (!forward) _backDropFilterController?.stop();
    popButtonAnimate(context, forward);

    _backgroundOpacityController = AnimationController(
      duration: Duration(milliseconds: _animateDuration),
      vsync: this,
    );
    final _backgroundOpacityCurve = CurvedAnimation(
      parent: _backgroundOpacityController,
      curve: forward ? Curves.easeInOut : Curves.easeIn,
    );
    _backgroundOpacityAnimation = Tween(
      begin: forward ? 0.0 : _backgroundOpacity,
      end: forward ? 1.0 : 0.0,
    ).animate(_backgroundOpacityCurve)
      ..addListener(() {
        _backgroundOpacity = _backgroundOpacityAnimation.value;
        if (mounted) setState(() {});
      });

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
      end: forward ? backdropRadius : 0.0,
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

    _backgroundOpacityController.forward();
    await _backDropFilterController.forward();
    if (forward) entering = false;
  }

  double pythagoreanTheorem(double short, double long) {
    return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
  }

  Widget get popButton => Opacity(
        opacity: _popButtonOpacity,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: suSetWidth(MainPageState.bottomBarHeight),
              height: suSetHeight(MainPageState.bottomBarHeight),
              child: Transform.rotate(
                angle: _popButtonRotateAngle,
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: suSetWidth(48.0),
                ),
              ),
            ),
            onTap: willPop,
          ),
        ),
      );

  Widget wrapper(context, {Widget child}) {
    final double topOverflow = backdropRadius - Screens.height;
    final double horizontalOverflow = backdropRadius - Screens.width;

    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          left: 0.0,
          top: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: willPop,
            child: Container(
              color: Colors.black.withOpacity(0.3 * _backgroundOpacity),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 3.0 * _backgroundOpacity,
                  sigmaY: 3.0 * _backgroundOpacity,
                ),
                child: Text(" ", style: TextStyle(inherit: false)),
              ),
            ),
          ),
        ),
        Positioned(
          left: -horizontalOverflow,
          right: -horizontalOverflow,
          top: -topOverflow,
          bottom: -backdropRadius,
          child: Center(
            child: Container(
              width: _backdropFilterSize,
              height: _backdropFilterSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.4),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: willPop,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(backdropRadius * 2),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Text(" ", style: TextStyle(inherit: false)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: Screens.width,
            height: Screens.height,
            constraints: BoxConstraints(
              maxWidth: Screens.width,
              maxHeight: Screens.height,
            ),
            child: child ?? SizedBox(),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: Screens.bottomSafeHeight,
          child: popButton,
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
                    width: suSetWidth(80.0),
                    height: suSetWidth(80.0),
                    decoration: BoxDecoration(
                      color: itemColors[index],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/addButton/${itemTitles[index]}.svg",
                        color: Colors.white,
                        width: suSetWidth(32.0),
                      ),
                    ),
                  ),
                  emptyDivider(height: suSetHeight(10.0)),
                  Text(
                    itemTitles[index],
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: suSetSp(20.0),
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
    if (entering || popping) return false;

    popping = true;
    await backDropFilterAnimate(context, false);
    await Future.delayed(Duration(milliseconds: _animateDuration), () {
      navigatorState.pop();
    });
    return false;
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
