///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 10:06
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class FixedAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;

  const FixedAppBar({
    Key key,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.title,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: suSetHeight(kAppBarHeight) + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        boxShadow: elevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: Color(0x0d000000),
                  blurRadius: suSetHeight(elevation * 1.0),
                  offset: Offset(0, elevation * 2.0),
                ),
              ]
            : null,
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: Row(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop()) BackButton(),
          Expanded(
            child: DefaultTextStyle(
              child: _title,
              style: Theme.of(context).textTheme.title.copyWith(fontSize: suSetSp(23.0)),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              (actions?.isEmpty ?? false))
            SizedBox(width: 48.0),
          if (actions?.isNotEmpty ?? false) ...actions,
        ],
      ),
    );
  }
}
