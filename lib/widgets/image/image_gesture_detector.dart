import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import 'package:openjmu/widgets/image/image_viewer.dart';

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
          (((enableTapPop ?? false) && context != null)
              ? () {
                  imageViewerState.pop();
                  if (heroPrefix != null) slidePageKey.currentState.popPage();
                  Navigator.pop(context);
                }
              : null),
      onLongPress: onLongPress,
      child: child,
    );
  }
}
