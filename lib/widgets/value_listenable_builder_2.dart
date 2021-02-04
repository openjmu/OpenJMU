///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/4/21 5:33 PM
///
import 'package:flutter/widgets.dart';

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    Key key,
    @required this.firstNotifier,
    @required this.secondNotifier,
    @required this.builder,
    this.child,
  }) : super(key: key);

  final ValueNotifier<A> firstNotifier;
  final ValueNotifier<B> secondNotifier;
  final Widget Function(BuildContext, A, B, Widget) builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: firstNotifier,
      child: child,
      builder: (_, A first, Widget firstW) => ValueListenableBuilder<B>(
        valueListenable: secondNotifier,
        builder: (BuildContext context, B second, __) {
          return builder(context, first, second, child);
        },
      ),
    );
  }
}
