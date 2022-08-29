///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-12-26 14:08
///
import 'package:flutter/widgets.dart';

class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    Key? key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
    this.index = 0,
    this.children = const <Widget>[],
  }) : super(key: key);

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;
  final int? index;
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late final List<bool> _activatedList = List<bool>.generate(
    widget.children.length,
    (int i) => i == widget.index,
  );

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Activate new index when it's changed between widgets update.
    if (oldWidget.index != widget.index) {
      _activateIndex(widget.index);
    }
  }

  void _activateIndex(int? index) {
    if (index == null) {
      return;
    }
    if (!_activatedList[index]) {
      setState(() {
        _activatedList[index] = true;
      });
    }
  }

  List<Widget> _buildChildren(BuildContext context) {
    return List<Widget>.generate(
      widget.children.length,
      (int i) {
        if (_activatedList[i]) {
          return widget.children[i];
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      index: widget.index,
      children: _buildChildren(context),
    );
  }
}
