///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-20 16:36
///
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.dragStartBehavior = DragStartBehavior.start,
    this.trackWidth = 50,
    this.trackHeight = 28,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? trackColor;
  final Color? thumbColor;
  final DragStartBehavior dragStartBehavior;
  final double trackWidth;
  final double trackHeight;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty(
        'value',
        value: value,
        ifTrue: 'on',
        ifFalse: 'off',
        showName: true,
      ),
    );
    properties.add(
      ObjectFlagProperty<ValueChanged<bool>>(
        'onChanged',
        onChanged,
        ifNull: 'disabled',
      ),
    );
  }
}

class _CustomSwitchState extends State<CustomSwitch>
    with TickerProviderStateMixin {
  late TapGestureRecognizer _tap;
  late HorizontalDragGestureRecognizer _drag;

  late AnimationController _positionController;
  late CurvedAnimation position;

  late AnimationController _reactionController;
  late Animation<double> _reaction;

  bool get isInteractive => widget.onChanged != null;

  bool needsPositionAnimation = false;

  double get _kTrackInnerStart => widget.trackHeight / 2.0;

  double get _kTrackInnerEnd => widget.trackWidth - _kTrackInnerStart;

  double get _kTrackInnerLength => _kTrackInnerEnd - _kTrackInnerStart;

  @override
  void initState() {
    super.initState();

    _tap = TapGestureRecognizer()
      ..onTapDown = _handleTapDown
      ..onTapUp = _handleTapUp
      ..onTap = _handleTap
      ..onTapCancel = _handleTapCancel;
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..dragStartBehavior = widget.dragStartBehavior;

    _positionController = AnimationController(
      duration: _kToggleDuration,
      value: widget.value ? 1.0 : 0.0,
      vsync: this,
    );
    position = CurvedAnimation(
      parent: _positionController,
      curve: Curves.linear,
    );
    _reactionController = AnimationController(
      duration: _kReactionDuration,
      vsync: this,
    );
    _reaction = CurvedAnimation(
      parent: _reactionController,
      curve: Curves.ease,
    );
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _drag.dragStartBehavior = widget.dragStartBehavior;

    if (needsPositionAnimation || oldWidget.value != widget.value)
      _resumePositionAnimation(isLinear: needsPositionAnimation);
  }

  void _resumePositionAnimation({bool isLinear = true}) {
    needsPositionAnimation = false;
    position
      ..curve = isLinear ? Curves.linear : Curves.ease
      ..reverseCurve = isLinear ? Curves.linear : Curves.ease.flipped;
    if (widget.value)
      _positionController.forward();
    else
      _positionController.reverse();
  }

  void _handleTapDown(TapDownDetails details) {
    if (isInteractive) {
      needsPositionAnimation = false;
    }
    _reactionController.forward();
  }

  void _handleTap() {
    if (isInteractive) {
      widget.onChanged!(!widget.value);
      _emitVibration();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (isInteractive) {
      needsPositionAnimation = false;
      _reactionController.reverse();
    }
  }

  void _handleTapCancel() {
    if (isInteractive) {
      _reactionController.reverse();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) {
      needsPositionAnimation = false;
      _reactionController.forward();
      _emitVibration();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      position
        ..curve = Curves.linear
        ..reverseCurve = Curves.linear;
      final double delta = details.primaryDelta! / _kTrackInnerLength;
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          _positionController.value -= delta;
          break;
        case TextDirection.ltr:
          _positionController.value += delta;
          break;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    // Deferring the animation to the next build phase.
    setState(() {
      needsPositionAnimation = true;
    });
    // Call onChanged when the user's intent to change value is clear.
    if (position.value >= 0.5 != widget.value) {
      widget.onChanged!(!widget.value);
    }
    _reactionController.reverse();
  }

  void _emitVibration() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        HapticFeedback.lightImpact();
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (needsPositionAnimation) {
      _resumePositionAnimation();
    }
    return Opacity(
      opacity: widget.onChanged == null ? _kCustomSwitchDisabledOpacity : 1.0,
      child: _CustomSwitchRenderObjectWidget(
        value: widget.value,
        activeColor: CupertinoDynamicColor.resolve(
          widget.activeColor ?? CupertinoColors.systemGreen,
          context,
        ),
        trackColor: CupertinoDynamicColor.resolve(
          widget.trackColor ?? CupertinoColors.secondarySystemFill,
          context,
        ),
        thumbColor: CupertinoDynamicColor.resolve(
          widget.thumbColor ?? CupertinoColors.white,
          context,
        ),
        onChanged: widget.onChanged,
        textDirection: Directionality.of(context),
        state: this,
        trackWidth: widget.trackWidth,
        trackHeight: widget.trackHeight,
      ),
    );
  }

  @override
  void dispose() {
    _tap.dispose();
    _drag.dispose();

    _positionController.dispose();
    _reactionController.dispose();
    super.dispose();
  }
}

class _CustomSwitchRenderObjectWidget extends LeafRenderObjectWidget {
  const _CustomSwitchRenderObjectWidget({
    Key? key,
    required this.value,
    required this.activeColor,
    required this.trackColor,
    required this.thumbColor,
    required this.onChanged,
    required this.textDirection,
    required this.state,
    required this.trackWidth,
    required this.trackHeight,
  }) : super(key: key);

  final bool value;
  final Color activeColor;
  final Color trackColor;
  final Color thumbColor;
  final ValueChanged<bool>? onChanged;
  final _CustomSwitchState state;
  final TextDirection textDirection;
  final double trackWidth;
  final double trackHeight;

  @override
  _RenderCustomSwitch createRenderObject(BuildContext context) {
    return _RenderCustomSwitch(
      value: value,
      activeColor: activeColor,
      trackColor: trackColor,
      thumbColor: thumbColor,
      onChanged: onChanged,
      textDirection: textDirection,
      state: state,
      trackWidth: trackWidth,
      trackHeight: trackHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCustomSwitch renderObject,
  ) {
    renderObject
      ..value = value
      ..activeColor = activeColor
      ..trackColor = trackColor
      ..thumbColor = thumbColor
      ..onChanged = onChanged
      ..textDirection = textDirection;
  }
}

const double _kSwitchWidth = 59.0;
const double _kSwitchHeight = 39.0;
// Opacity of a disabled switch, as eye-balled from iOS Simulator on Mac.
const double _kCustomSwitchDisabledOpacity = 0.5;

const Duration _kReactionDuration = Duration(milliseconds: 300);
const Duration _kToggleDuration = Duration(milliseconds: 200);

class _RenderCustomSwitch extends RenderConstrainedBox {
  _RenderCustomSwitch({
    required bool value,
    required Color activeColor,
    required Color trackColor,
    required Color thumbColor,
    ValueChanged<bool>? onChanged,
    required TextDirection textDirection,
    required _CustomSwitchState state,
    required double trackWidth,
    required double trackHeight,
  })  : _value = value,
        _activeColor = activeColor,
        _trackColor = trackColor,
        _thumbPainter = CupertinoThumbPainter.switchThumb(color: thumbColor),
        _onChanged = onChanged,
        _textDirection = textDirection,
        _state = state,
        _trackWidth = trackWidth,
        _trackHeight = trackHeight,
        super(
          additionalConstraints: const BoxConstraints.tightFor(
            width: _kSwitchWidth,
            height: _kSwitchHeight,
          ),
        ) {
    state.position.addListener(markNeedsPaint);
    state._reaction.addListener(markNeedsPaint);
  }

  final _CustomSwitchState _state;

  bool get value => _value;
  bool _value;

  set value(bool value) {
    if (value == _value) {
      return;
    }
    _value = value;
    markNeedsSemanticsUpdate();
  }

  Color get activeColor => _activeColor;
  Color _activeColor;

  set activeColor(Color value) {
    if (value == _activeColor) {
      return;
    }
    _activeColor = value;
    markNeedsPaint();
  }

  Color get trackColor => _trackColor;
  Color _trackColor;

  set trackColor(Color value) {
    if (value == _trackColor) {
      return;
    }
    _trackColor = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbPainter.color;
  CupertinoThumbPainter _thumbPainter;

  set thumbColor(Color value) {
    if (value == thumbColor) {
      return;
    }
    _thumbPainter = CupertinoThumbPainter.switchThumb(color: value);
    markNeedsPaint();
  }

  ValueChanged<bool>? get onChanged => _onChanged;
  ValueChanged<bool>? _onChanged;

  set onChanged(ValueChanged<bool>? value) {
    if (value == _onChanged) {
      return;
    }
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  double get trackWidth => _trackWidth;
  double _trackWidth;

  set trackWidth(double value) {
    if (_trackWidth == value) {
      return;
    }
    _trackWidth = value;
    markNeedsPaint();
  }

  double get trackHeight => _trackHeight;
  double _trackHeight;

  set trackHeight(double value) {
    if (_trackHeight == value) {
      return;
    }
    _trackHeight = value;
    markNeedsPaint();
  }

  bool get isInteractive => onChanged != null;

  double get _kTrackRadius => _trackHeight / 2.0;

  double get _kTrackInnerStart => _trackHeight / 2.0;

  double get _kTrackInnerEnd => _trackWidth - _kTrackInnerStart;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      _state._drag.addPointer(event);
      _state._tap.addPointer(event);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    if (isInteractive) {
      config.onTap = _state._handleTap;
    }

    config.isEnabled = isInteractive;
    config.isToggled = _value;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final double currentValue = _state.position.value;
    final double currentReactionValue = _state._reaction.value;

    final double visualPosition;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - currentValue;
        break;
      case TextDirection.ltr:
        visualPosition = currentValue;
        break;
    }

    final Paint paint = Paint()
      ..color = Color.lerp(trackColor, activeColor, currentValue)!;

    final Rect trackRect = Rect.fromLTWH(
      offset.dx + (size.width - _trackWidth) / 2.0,
      offset.dy + (size.height - _trackHeight) / 2.0,
      _trackWidth,
      _trackHeight,
    );
    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(_kTrackRadius),
    );
    canvas.drawRRect(trackRRect, paint);

    final double currentThumbExtension =
        CupertinoThumbPainter.extension * currentReactionValue;
    final double thumbLeft = lerpDouble(
      trackRect.left + _kTrackInnerStart - CupertinoThumbPainter.radius,
      trackRect.left +
          _kTrackInnerEnd -
          CupertinoThumbPainter.radius -
          currentThumbExtension,
      visualPosition,
    )!;
    final double thumbRight = lerpDouble(
      trackRect.left +
          _kTrackInnerStart +
          CupertinoThumbPainter.radius +
          currentThumbExtension,
      trackRect.left + _kTrackInnerEnd + CupertinoThumbPainter.radius,
      visualPosition,
    )!;
    final double thumbCenterY = offset.dy + size.height / 2.0;
    final Rect thumbBounds = Rect.fromLTRB(
      thumbLeft,
      thumbCenterY - CupertinoThumbPainter.radius,
      thumbRight,
      thumbCenterY + CupertinoThumbPainter.radius,
    );

    _clipRRectLayer.layer = context.pushClipRRect(
      needsCompositing,
      Offset.zero,
      thumbBounds,
      trackRRect,
      (PaintingContext innerContext, Offset offset) {
        _thumbPainter.paint(innerContext.canvas, thumbBounds);
      },
      oldLayer: _clipRRectLayer.layer,
    );
  }

  final LayerHandle<ClipRRectLayer> _clipRRectLayer =
      LayerHandle<ClipRRectLayer>();

  @override
  void dispose() {
    _clipRRectLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      FlagProperty(
        'value',
        value: value,
        ifTrue: 'checked',
        ifFalse: 'unchecked',
        showName: true,
      ),
    );
    description.add(
      FlagProperty(
        'isInteractive',
        value: isInteractive,
        ifTrue: 'enabled',
        ifFalse: 'disabled',
        showName: true,
        defaultValue: true,
      ),
    );
  }
}
