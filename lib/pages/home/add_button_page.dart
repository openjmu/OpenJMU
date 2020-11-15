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

class _AddingButtonPageState extends State<AddingButtonPage>
    with TickerProviderStateMixin {
  final List<String> itemIcons = <String>[
    R.ASSETS_ICONS_ADD_BUTTON_GUANGCHANG_SVG,
    R.ASSETS_ICONS_ADD_BUTTON_JISHI_SVG,
  ];
  final List<String> itemTitles = <String>['广场', '集市'];
  final List<Color> itemColors = <Color>[Colors.orange, Colors.indigoAccent];
  final List<VoidCallback> itemOnTap = <VoidCallback>[
    () {
      navigatorState.pushNamed(Routes.openjmuPublishPost);
    },
    () {
      navigatorState.pushNamed(Routes.openjmuPublishTeamPost);
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
    SchedulerBinding.instance
        .addPostFrameCallback((_) => backDropFilterAnimate(context, true));
  }

  @override
  void dispose() {
    _backgroundOpacityController?.dispose();
    _popButtonController?.dispose();
    _popButtonOpacityController?.dispose();
    for (final AnimationController controller in _itemAnimateControllers) {
      controller?.dispose();
    }
    for (final AnimationController controller
        in _itemOpacityAnimateControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void initItemsAnimation() {
    _itemOffset = List<double>.generate(itemTitles.length, (_) => 0.0);
    _itemAnimations = List<Animation<double>>(itemTitles.length);
    _itemCurveAnimations = List<CurvedAnimation>(itemTitles.length);
    _itemAnimateControllers = List<AnimationController>(itemTitles.length);
    _itemOpacity = List<double>.generate(itemTitles.length, (_) => 0.01);
    _itemOpacityAnimations = List<Animation<double>>(itemTitles.length);
    _itemOpacityCurveAnimations = List<CurvedAnimation>(itemTitles.length);
    _itemOpacityAnimateControllers =
        List<AnimationController>(itemTitles.length);

    for (int i = 0; i < itemTitles.length; i++) {
      _itemAnimateControllers[i] = AnimationController(
        duration: _animateDuration.milliseconds,
        vsync: this,
      );
      _itemCurveAnimations[i] = CurvedAnimation(
        parent: _itemAnimateControllers[i],
        curve: Curves.ease,
      );
      _itemAnimations[i] = Tween<double>(
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
      _itemOpacityAnimations[i] = Tween<double>(
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
      Future<void>.delayed((i * 50).milliseconds, () {
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

  void popButtonAnimate(BuildContext context, bool forward) {
    if (!forward) {
      _popButtonController?.stop();
      _popButtonOpacityController?.stop();
    }
    const double rotateDegree = 45 * (math.pi / 180) * 3;

    _popButtonController = AnimationController(
      duration: _animateDuration.milliseconds,
      vsync: this,
    );
    _popButtonOpacityController = AnimationController(
      duration: _animateDuration.milliseconds,
      vsync: this,
    );
    final CurvedAnimation _popButtonCurve = CurvedAnimation(
      parent: _popButtonController,
      curve: Curves.easeInOut,
    );
    _popButtonAnimation = Tween<double>(
      begin: forward ? 0.0 : _popButtonRotateAngle,
      end: forward ? rotateDegree : 0.0,
    ).animate(_popButtonCurve)
      ..addListener(() {
        setState(() {
          _popButtonRotateAngle = _popButtonAnimation.value;
        });
      });
    _popButtonOpacityAnimation = Tween<double>(
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

  Future<void> backDropFilterAnimate(BuildContext context, bool forward) async {
    popButtonAnimate(context, forward);

    _backgroundOpacityController = AnimationController(
      duration: _animateDuration.milliseconds,
      vsync: this,
    );
    final CurvedAnimation _backgroundOpacityCurve = CurvedAnimation(
      parent: _backgroundOpacityController,
      curve: forward ? Curves.easeInOut : Curves.easeIn,
    );
    _backgroundOpacityAnimation = Tween<double>(
      begin: forward ? 0.0 : _backgroundOpacity,
      end: forward ? 1.0 : 0.0,
    ).animate(_backgroundOpacityCurve)
      ..addListener(() {
        _backgroundOpacity = _backgroundOpacityAnimation.value;
        if (mounted) {
          setState(() {});
        }
      });

    if (forward) {
      Future<void>.delayed(
          (_animateDuration ~/ 2).milliseconds, () => itemsAnimate(true));
    } else {
      itemsAnimate(false);
    }

    _backgroundOpacityController.forward();
    if (forward) {
      entering = false;
    }
  }

  Widget get popButton => Opacity(
        opacity: _popButtonOpacity,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: MainPageState.bottomBarHeight.w,
              height: MainPageState.bottomBarHeight.w,
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 20.w,
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
                  size: 48.w,
                ),
              ),
            ),
            onTap: willPop,
          ),
        ),
      );

  Widget wrapper(BuildContext context, {Widget child}) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: willPop,
            child: Container(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(0.6 * _backgroundOpacity),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 3.0 * _backgroundOpacity,
                  sigmaY: 3.0 * _backgroundOpacity,
                ),
                child: const Text(' ', style: TextStyle(inherit: false)),
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
            child: child ?? const SizedBox.shrink(),
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
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: itemColors[index],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        itemIcons[index],
                        color: Colors.white,
                        width: 40.w,
                      ),
                    ),
                  ),
                  emptyDivider(height: 10.h),
                  Text(
                    itemTitles[index],
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 20.sp),
                  ),
                ],
              ),
              onTap: () => itemOnTap[index](),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> willPop() async {
    if (entering || popping) {
      return false;
    }

    popping = true;
    await backDropFilterAnimate(context, false);
    await Future<void>.delayed(Duration(milliseconds: _animateDuration), () {
      navigatorState.pop();
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: entering || popping,
      child: WillPopScope(
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
                children: List<Widget>.generate(
                  itemTitles.length,
                  (int i) => item(context, i),
                ),
              ),
              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
    );
  }
}
