import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ImageGestureDetector extends StatefulWidget {
  final Widget child;
  final BuildContext context;
  final Function onLongPress;
  final bool enableTapPop;
  final GlobalKey<ExtendedImageSlidePageState> slidePageKey;

  const ImageGestureDetector({
    Key key,
    this.child,
    this.context,
    this.onLongPress,
    this.enableTapPop,
    this.slidePageKey,
  }) : super(key: key);

  @override
  _ImageGestureDetectorState createState() => _ImageGestureDetectorState();
}

class _ImageGestureDetectorState extends State<ImageGestureDetector> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ((widget.enableTapPop ?? false) && widget.context != null)
          ? () {
              widget.slidePageKey.currentState.popPage();
              Navigator.pop(widget.context);
            }
          : null,
      onLongPress: (widget.onLongPress != null) ? () => widget.onLongPress() : null,
      child: widget.child,
    );
  }
}
