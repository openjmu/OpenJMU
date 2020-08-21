///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-31 14:32
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class NoRoutePage extends StatelessWidget {
  final String route;

  const NoRoutePage({
    Key key,
    @required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'You\'re visiting\n'),
                TextSpan(
                    text: '$route\n',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'which result nothing...'),
              ],
              style: TextStyle(fontSize: suSetSp(22.0)),
            ),
          ),
          BackButton(),
        ],
      ),
    );
  }
}
