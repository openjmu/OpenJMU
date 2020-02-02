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
  final List<String> itemTitles = ['广场', '集市'];
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

  /// Animation.
  /// Boolean to prevent duplicate pop.
  bool entering = true;
  bool popping = false;
  double _backgroundOpacity = 0.0;
  double _popButtonOpacity = 0.01;
  double _popButtonRotateAngle = 0.0;
  Animation<double> _backgroundOpacityAnimation;
  AnimationController _backgroundOpacityController;
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
    super.initState();
    initItemsAnimation();
    SchedulerBinding.instance.addPostFrameCallback((_) => backDropFilterAnimate(context, true));
  }

  @override
  void dispose() {
    _backgroundOpacityController?.dispose();
    _popButtonController?.dispose();
    _popButtonOpacityController?.dispose();
    _itemAnimateControllers?.forEach((controller) {
      controller?.dispose();
    });
    _itemOpacityAnimateControllers?.forEach((controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  void initItemsAnimation() {
    _itemOffset = List<double>.generate(itemTitles.length, (_) => 0.0);
    _itemAnimations = List(itemTitles.length);
    _itemCurveAnimations = List(itemTitles.length);
    _itemAnimateControllers = List(itemTitles.length);
    _itemOpacity = List<double>.generate(itemTitles.length, (_) => 0.01);
    _itemOpacityAnimations = List(itemTitles.length);
    _itemOpacityCurveAnimations = List(itemTitles.length);
    _itemOpacityAnimateControllers = List(itemTitles.length);

    for (int i = 0; i < itemTitles.length; i++) {
      _itemAnimateControllers[i] = AnimationController(
        duration: _animateDuration.milliseconds,
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
        duration: _animateDuration.milliseconds,
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
      Future.delayed((i * 50).milliseconds, () {
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

    _popButtonController = AnimationController(
      duration: _animateDuration.milliseconds,
      vsync: this,
    );
    _popButtonOpacityController = AnimationController(
      duration: _animateDuration.milliseconds,
      vsync: this,
    );
    final _popButtonCurve = CurvedAnimation(
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
    popButtonAnimate(context, forward);

    _backgroundOpacityController = AnimationController(
      duration: _animateDuration.milliseconds,
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

    if (forward) {
      Future.delayed((_animateDuration ~/ 2).milliseconds, () => itemsAnimate(true));
    } else {
      itemsAnimate(false);
    }

    _backgroundOpacityController.forward();
    if (forward) entering = false;
  }

  Widget get popButton => Opacity(
        opacity: _popButtonOpacity,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: suSetWidth(MainPageState.bottomBarHeight),
              height: suSetHeight(MainPageState.bottomBarHeight),
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: suSetWidth(20.0),
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    spreadRadius: 0.0,
                  ),
                ],
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: _popButtonRotateAngle,
                child: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(currentIsDark ? 0.7 : 1.0),
                  size: suSetWidth(48.0),
                ),
              ),
            ),
            onTap: willPop,
          ),
        ),
      );

  Widget wrapper(context, {Widget child}) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: willPop,
            child: Container(
              color: Theme.of(context).primaryColor.withOpacity(0.6 * _backgroundOpacity),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 3.0 * _backgroundOpacity,
                  sigmaY: 3.0 * _backgroundOpacity,
                ),
                child: Text(' ', style: TextStyle(inherit: false)),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: Screens.width,
            height: Screens.height,
            constraints: BoxConstraints(maxWidth: Screens.width, maxHeight: Screens.height),
            child: child ?? SizedBox.shrink(),
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
                    decoration: BoxDecoration(color: itemColors[index], shape: BoxShape.circle),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/addButton/${itemTitles[index]}.svg',
                        color: Colors.white,
                        width: suSetWidth(32.0),
                      ),
                    ),
                  ),
                  emptyDivider(height: suSetHeight(10.0)),
                  Text(
                    itemTitles[index],
                    style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
                  ),
                ],
              ),
              onTap: () => itemOnTap[index](context),
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
              children: List<Widget>.generate(itemTitles.length, (i) => item(context, i)),
            ),
            SizedBox(height: suSetHeight(120.0)),
          ],
        ),
      ),
    );
  }
}
