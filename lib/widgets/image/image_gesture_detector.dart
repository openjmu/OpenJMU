import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import 'package:openjmu/widgets/image/image_viewer.dart';

class ImageGestureDetector extends StatelessWidget {
  final Widget child;
  final BuildContext context;
  final ImageViewerState imageViewerState;
  final GlobalKey<ExtendedImageSlidePageState> slidePageKey;
  final Function onLongPress;
  final bool enableTapPop;
  final String heroPrefix;

  const ImageGestureDetector({
    Key key,
    this.child,
    this.context,
    this.imageViewerState,
    this.slidePageKey,
    this.onLongPress,
    this.enableTapPop,
    this.heroPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ((enableTapPop ?? false) && context != null)
          ? () {
              imageViewerState.pop();
              if (heroPrefix != null) slidePageKey.currentState.popPage();
              Navigator.pop(context);
            }
          : null,
      onLongPress: (onLongPress != null) ? () => onLongPress() : null,
      child: child,
    );
  }
}
