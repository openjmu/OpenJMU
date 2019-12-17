///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 10:06
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      height: suSetHeight(kAppBarHeight) + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        boxShadow: elevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: suSetHeight(elevation * 2.0),
                ),
              ]
            : null,
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: Row(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop())
            BackButton(),
          Expanded(child: _title),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              actions == null)
            SizedBox.fromSize(size: Size.square(56.0)),
          if (actions != null) ...actions,
        ],
      ),
    );
  }
}

class SliverFixedAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return FixedAppBar(
      title: Text(
        "集市动态",
        style: Theme.of(context).textTheme.title.copyWith(
              fontSize: suSetSp(21.0),
            ),
      ),
      centerTitle: true,
    );
  }

  @override
  double get maxExtent => suSetHeight(kAppBarHeight) + Screen.topSafeHeight;

  @override
  double get minExtent => suSetHeight(kAppBarHeight) + Screen.topSafeHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
