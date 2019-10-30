import 'package:flutter/material.dart';

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

class _ImageGestureDetectorState extends State<ImageGestureDetector>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ((widget.enableTapPop ?? false) && widget.context != null)
          ? () {
              Navigator.pop(widget.context);
            }
          : null,
      onLongPress: (widget.onLongPress != null) ? widget.onLongPress : null,
      child: widget.child,
    );
  }
}
