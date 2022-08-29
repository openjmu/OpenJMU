///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/11/21 12:07 AM
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/utils/emoji_utils.dart';

class EmojiKeyboardWrapper extends StatefulWidget {
  const EmojiKeyboardWrapper({
    super.key,
    required this.child,
    required this.controller,
    required this.emoticonPadNotifier,
    this.bottomPaddingColor,
  }) ;

  final Widget child;
  final TextEditingController controller;
  final ValueNotifier<bool> emoticonPadNotifier;
  final Color? bottomPaddingColor;

  @override
  _EmojiKeyboardWrapperState createState() => _EmojiKeyboardWrapperState();
}

class _EmojiKeyboardWrapperState extends State<EmojiKeyboardWrapper> {
  double _keyboardHeight = 0;

  Widget _emoticonPad(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.emoticonPadNotifier,
      builder: (_, bool value, __) => EmojiPad(
        active: value,
        height: _keyboardHeight,
        controller: widget.controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double kh = mq.viewInsets.bottom;
    if (kh > 0 && kh >= _keyboardHeight) {
      widget.emoticonPadNotifier.value = false;
    }
    _keyboardHeight = math.max(kh, _keyboardHeight);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.child,
            _emoticonPad(context),
            ValueListenableBuilder<bool>(
              valueListenable: widget.emoticonPadNotifier,
              builder: (_, bool value, __) => Container(
                height: value
                    ? 0
                    : math.max(mq.viewInsets.bottom, mq.padding.bottom),
                color: widget.bottomPaddingColor ??
                    Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
