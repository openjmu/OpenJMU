///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-31 14:32
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class NoRoutePage extends StatelessWidget {
  const NoRoutePage({
    Key key,
    @required this.route,
  }) : super(key: key);

  final String route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(text: 'You\'re visiting\n'),
                TextSpan(
                    text: '$route\n',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: 'which result nothing...'),
              ],
              style: TextStyle(fontSize: suSetSp(22.0)),
            ),
          ),
          const BackButton(),
        ],
      ),
    );
  }
}
