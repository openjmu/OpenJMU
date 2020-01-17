///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-18 11:43
///
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';

class NotificationEntryPage extends StatefulWidget {
  @override
  _NotificationEntryPageState createState() => _NotificationEntryPageState();
}

class _NotificationEntryPageState extends State<NotificationEntryPage>
    with TickerProviderStateMixin {
  final items = <Map<String, dynamic>>[
    {
      "name": "广场",
      "color": Colors.orange,
      "notifications": Provider.of<NotificationProvider>(
        currentContext,
        listen: false,
      ).notifications,
      "onTap": (context) async {
        navigatorState.pushNamed(Routes.OPENJMU_NOTIFICATIONS);
      },
    },
    {
      "name": "集市",
      "color": Colors.indigoAccent,
      "notifications": Provider.of<NotificationProvider>(
        currentContext,
        listen: false,
      ).teamNotifications,
      "onTap": (context) async {
        navigatorState.pushNamed(Routes.OPENJMU_TEAM_NOTIFICATIONS);
      },
    },
  ];

  final int _animateDuration = 300;
  double get backdropRadius => Screens.width / 2;

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
    _backgroundOpacityController?.dispose();
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
    _itemOffset = <double>[for (int i = 0; i < items.length; i++) 0.0];
    _itemAnimations = List(items.length);
    _itemCurveAnimations = List(items.length);
    _itemAnimateControllers = List(items.length);
    _itemOpacity = <double>[for (int i = 0; i < items.length; i++) 0.01];
    _itemOpacityAnimations = List(items.length);
    _itemOpacityCurveAnimations = List(items.length);
    _itemOpacityAnimateControllers = List(items.length);

    for (int i = 0; i < items.length; i++) {
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
    final _backDropFilterCurve = CurvedAnimation(
      parent: _backDropFilterController,
      curve: forward ? Curves.easeInOut : Curves.easeIn,
    );
    _backDropFilterAnimation = Tween(
      begin: forward ? 0.0 : _backdropFilterSize,
      end: forward ? backdropRadius * 2 : 0.0,
    ).animate(_backDropFilterCurve)
      ..addListener(() {
        _backdropFilterSize = _backDropFilterAnimation.value;
        if (mounted) setState(() {});
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
          right: suSetWidth(10.0) - backdropRadius,
          top: Screens.topSafeHeight - backdropRadius,
          child: Container(
            width: _backdropFilterSize,
            height: _backdropFilterSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
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
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: Screens.width,
            height: Screens.height,
            constraints: BoxConstraints(
              maxWidth: Screens.width,
              maxHeight: Screens.height,
            ),
            child: child ?? SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: Screens.topSafeHeight,
          right: suSetWidth(10.0),
          child: popButton,
        ),
      ],
    );
  }

  Widget item(BuildContext context, int index) {
    final stepRadius = 90 / (items.length * 2);
    final itemRadius = stepRadius * (index + 1);
    final itemRadians = itemRadius * math.pi / 180;
    final right = math.cos(itemRadians) * backdropRadius / 2.1;
    final top = math.sin(itemRadians) * backdropRadius / 2.1;
    final itemIndex = index ~/ 2;
    return Positioned(
      right: right + _itemOffset[itemIndex],
      top: Screens.topSafeHeight + top + _itemOffset[itemIndex],
      child: index.isEven
          ? Opacity(
              opacity: _itemOpacity[itemIndex],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: suSetWidth(70.0),
                  height: suSetWidth(70.0),
                  decoration: BoxDecoration(
                    color: items[itemIndex]['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Center(
                        child: SvgPicture.asset(
                          "assets/icons/addButton/${items[itemIndex]['name']}.svg",
                          color: Colors.white,
                          width: suSetWidth(28.0),
                        ),
                      ),
                      if (items[itemIndex]['notifications'].total > 0)
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: Badge(
                            badgeContent: Text(
                              items[itemIndex]['notifications'].total.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: suSetSp(20.0),
                              ),
                            ),
                            badgeColor: currentThemeColor,
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () => items[itemIndex]['onTap'](context),
              ),
            )
          : SizedBox.shrink(),
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
        child: SizedBox.fromSize(
          size: Size.square(Screens.width / 3 * 2),
          child: Stack(
            children: List<Widget>.generate(
              items.length * 2 - 1,
              (i) => item(context, i),
            ),
          ),
        ),
      ),
    );
  }
}
