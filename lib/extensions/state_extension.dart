///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/9/15 14:06
///
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:flutter/widgets.dart';

extension SafeSetStateExtension on State {
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding == false) {
      setState(() {});
    }
  }
}
