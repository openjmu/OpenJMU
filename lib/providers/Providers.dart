///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:53
///
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:OpenJMU/providers/MessagesProvider.dart';

export 'MessagesProvider.dart';

ChangeNotifierProvider<T> _buildProvider<T extends ChangeNotifier>(T value) {
  return ChangeNotifierProvider<T>.value(value: value);
}

List<SingleChildCloneableWidget> get providers => _providers;

final _providers = [
  _buildProvider<MessagesProvider>(MessagesProvider()..initListener()),
];
