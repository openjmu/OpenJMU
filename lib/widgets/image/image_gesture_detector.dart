import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'image_viewer.dart';

class ImageGestureDetector extends StatelessWidget {
  const ImageGestureDetector({
    Key key,
    this.child,
    this.context,
    this.imageViewerState,
    this.slidePageKey,
    this.onTap,
    this.onLongPress,
    this.enableTapPop,
    this.heroPrefix,
  }) : super(key: key);

  final Widget child;
  final BuildContext context;
  final ImageViewerState imageViewerState;
  final GlobalKey<ExtendedImageSlidePageState> slidePageKey;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool enableTapPop;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ??
          () {
            if ((enableTapPop ?? false) && context != null) {
              imageViewerState.pop();
              if (heroPrefix != null) {
                slidePageKey.currentState.popPage();
              }
              Navigator.pop(context);
            }
          },
      onLongPress: onLongPress,
      child: child,
    );
  }
}
