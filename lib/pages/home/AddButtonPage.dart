import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


class AddingButtonPage extends StatefulWidget {
    @override
    _AddingButtonPageState createState() => _AddingButtonPageState();
}

class _AddingButtonPageState extends State<AddingButtonPage> with SingleTickerProviderStateMixin {
    double backgroundSize = 0.0;
    AnimationController _backDropFilterAnimationController;
    Animation<double> _backDropFilterAnimation;

    @override
    void initState() {
        SchedulerBinding.instance.addPostFrameCallback((_) => backDropFilterAnimation(context));
        super.initState();
    }

    @override
    void dispose() {
        _backDropFilterAnimationController?.dispose();
        super.dispose();
    }

    void backDropFilterAnimation(context) {
        _backDropFilterAnimationController = AnimationController(
            duration: const Duration(milliseconds: 2000),
            vsync: this,
        );
        Animation _backDropFilterCurveAnimation = CurvedAnimation(
            parent: _backDropFilterAnimationController,
            curve: Curves.easeInOut,
        );
        _backDropFilterAnimation = Tween(
            begin: 0.0,
            end: pythagoreanTheorem(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
            ) * 2,
        ).animate(_backDropFilterCurveAnimation)
            ..addListener(() {
                setState(() {
                    backgroundSize = _backDropFilterAnimation.value;
                });
            });
        _backDropFilterAnimationController.forward();
    }

    double pythagoreanTheorem(double short, double long) {
        return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
    }

    @override
    Widget build(BuildContext context) {
        double horizontalOverflow = (MediaQuery.of(context).size.height - MediaQuery.of(context).size.width);
        double topOverflow = pythagoreanTheorem(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
        ) - MediaQuery.of(context).size.height;
        return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
                Positioned(
                    left: - horizontalOverflow,
                    right: - horizontalOverflow,
                    top: - topOverflow,
                    bottom: - MediaQuery.of(context).size.height,
                    child: Center(
                        child: SizedBox(
                            width: backgroundSize,
                            height: backgroundSize,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 2),
                                child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                                    child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                            padding: EdgeInsets.only(top: topOverflow),
                                            child: Text("test"),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}

