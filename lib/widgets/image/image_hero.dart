///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-05-07 20:11
///
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageHero extends StatefulWidget {
  const ImageHero({
    Key key,
    @required this.child,
    @required this.tag,
    @required this.slidePageKey,
    this.slideType = SlideType.onlyImage,
  }) : super(key: key);

  final Widget child;
  final SlideType slideType;
  final Object tag;
  final GlobalKey<ExtendedImageSlidePageState> slidePageKey;

  @override
  _ImageHeroState createState() => _ImageHeroState();
}

class _ImageHeroState extends State<ImageHero> {
  RectTween _rectTween = RectTween(begin: Rect.zero, end: Rect.zero);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag,
      createRectTween: (Rect begin, Rect end) {
        _rectTween = RectTween(begin: begin, end: end);
        return _rectTween;
      },
      // Make hero better when slides out.
      flightShuttleBuilder: (BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext) {
        // Make hero more smoothly.
        final Hero hero = (flightDirection == HeroFlightDirection.pop
            ? fromHeroContext.widget
            : toHeroContext.widget) as Hero;
        if (flightDirection == HeroFlightDirection.pop) {
          final bool fixTransform = widget.slideType == SlideType.onlyImage &&
              (widget.slidePageKey.currentState.offset != Offset.zero ||
                  widget.slidePageKey.currentState.scale != 1.0);

          final Widget toHeroWidget = (toHeroContext.widget as Hero).child;
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext buildContext, Widget child) {
              Widget animatedBuilderChild = hero.child;

              // Make hero more smoothly.
              animatedBuilderChild = Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 1 - animation.value,
                    child: UnconstrainedBox(
                      child: SizedBox(
                        width: _rectTween.begin.width,
                        height: _rectTween.begin.height,
                        child: toHeroWidget,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: animation.value,
                    child: animatedBuilderChild,
                  ),
                ],
              );

              // Fix transform when slides out.
              if (fixTransform) {
                final Tween<Offset> offsetTween = Tween<Offset>(
                  begin: Offset.zero,
                  end: widget.slidePageKey.currentState.offset,
                );

                final Tween<double> scaleTween = Tween<double>(
                  begin: 1.0,
                  end: widget.slidePageKey.currentState.scale,
                );
                animatedBuilderChild = Transform.translate(
                  offset: offsetTween.evaluate(animation),
                  child: Transform.scale(
                    scale: scaleTween.evaluate(animation),
                    child: animatedBuilderChild,
                  ),
                );
              }
              return animatedBuilderChild;
            },
          );
        }
        return hero.child;
      },
      child: widget.child,
    );
  }
}
