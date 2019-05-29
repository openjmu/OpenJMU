import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ImageGestureDetector extends StatefulWidget {
    final Widget child;
    final BuildContext context;
    final Function onLongPress;
    final bool enableTapPop;
    final bool enablePullDownPop;

    ImageGestureDetector({
        Key key,
        this.child,
        this.context,
        this.onLongPress,
        this.enableTapPop,
        this.enablePullDownPop,
    }) : super(key: key);

    @override
    _ImageGestureDetectorState createState() => _ImageGestureDetectorState();
}

class _ImageGestureDetectorState extends State<ImageGestureDetector> with TickerProviderStateMixin {

    AnimationController _pullDownAnimationController;
    Animation _pullDownCurveAnimation;
    Animation<double> _pullDownAnimation;
    Function _pullDownListener;
    Offset pullDownDragStart;
    Offset pullDownDragOffset = Offset(0, 0);

    @override
    void initState() {
        super.initState();
        _pullDownAnimationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
        _pullDownCurveAnimation = CurvedAnimation(parent: _pullDownAnimationController, curve: Curves.easeOut);
        _pullDownListener = () {
            setState(() { pullDownDragOffset = Offset(0, _pullDownAnimation.value); });
        };
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        pullDownDragStart = Offset(0, MediaQuery.of(widget.context).size.height / 2);
    }

    @override
    void dispose() {
        super.dispose();
        _pullDownAnimationController?.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: ((widget.enableTapPop ?? false) && widget.context != null) ? () {
                Navigator.pop(widget.context);
            } : null,
            onLongPress: (widget.onLongPress != null) ? widget.onLongPress : null,
            onVerticalDragDown: (widget.enablePullDownPop ?? false) ? (DragDownDetails detail) {
                pullDownDragOffset = Offset(0, 0);
            } : null,
            onVerticalDragUpdate: (widget.enablePullDownPop ?? false) ? (DragUpdateDetails detail) {
                Offset _o = detail.delta;
                pullDownDragOffset = pullDownDragOffset.translate(_o.dx, _o.dy);
                if (pullDownDragOffset.dy > 0) setState(() {});
            } : null,
            onVerticalDragEnd: (widget.enablePullDownPop ?? false) ? (DragEndDetails detail) {
                if (pullDownDragOffset.dy > 0) {
                    _pullDownAnimationController..stop()..reset();
                    _pullDownAnimation?.removeListener(_pullDownListener);
                    _pullDownAnimation = Tween(
                        begin: pullDownDragOffset.dy,
                        end: 0.0,
                    ).animate(_pullDownCurveAnimation)..addListener(_pullDownListener);
                    _pullDownAnimationController.forward();
                }
            } : null,
            child: Transform.translate(
                offset: pullDownDragOffset,
                child: widget.child,
            ),
        );
    }
}
