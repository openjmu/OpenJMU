///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/11/21 12:07 AM
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/utils/emoji_utils.dart';

class EmojiKeyboardWrapper extends StatefulWidget {
  const EmojiKeyboardWrapper({
    Key key,
    @required this.child,
    @required this.controller,
    @required this.emoticonPadNotifier,
  })  : assert(child != null),
        assert(controller != null),
        assert(emoticonPadNotifier != null),
        super(key: key);

  final Widget child;
  final TextEditingController controller;
  final ValueNotifier<bool> emoticonPadNotifier;

  @override
  _EmojiKeyboardWrapperState createState() => _EmojiKeyboardWrapperState();
}

class _EmojiKeyboardWrapperState extends State<EmojiKeyboardWrapper> {
  double _keyboardHeight = 0;

  Widget _emoticonPad(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.emoticonPadNotifier,
      builder: (_, bool value, __) => EmotionPad(
        active: value,
        height: _keyboardHeight,
        controller: widget.controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double kh = MediaQuery.of(context).viewInsets.bottom;
    if (kh > 0 && kh >= _keyboardHeight) {
      widget.emoticonPadNotifier.value = false;
    }
    _keyboardHeight = math.max(kh, _keyboardHeight ?? 0);

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
              builder: (_, bool value, __) => SizedBox(
                height: value ? 0 : MediaQuery.of(context).viewInsets.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
