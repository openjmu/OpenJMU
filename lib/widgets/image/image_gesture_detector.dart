import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ImageGestureDetector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ((enableTapPop ?? false) && context != null)
          ? () {
              slidePageKey.currentState.popPage();
              Navigator.pop(context);
            }
          : null,
      onLongPress: (onLongPress != null) ? () => onLongPress() : null,
      child: child,
    );
  }
}
