import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/announcement/AnnouncementDialog.dart';

class AnnouncementWidget extends StatelessWidget {
  final BuildContext context;
  final Color color;
  final double gap;
  final double radius;

  const AnnouncementWidget(
    this.context, {
    this.color,
    this.gap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: suSetSp(gap ?? 15.0),
          vertical: suSetSp(10.0),
        ),
        decoration: BoxDecoration(
          borderRadius: radius != null
              ? BorderRadius.circular(suSetSp(radius))
              : null,
          color: (color ?? ThemeUtils.defaultColor).withAlpha(0x44),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: suSetSp(6.0)),
              child: Icon(
                Icons.error_outline,
                size: suSetSp(18.0),
                color: color ?? ThemeUtils.defaultColor,
              ),
            ),
            Expanded(
              child: Text(
                "${Configs.announcements[0]['title']}",
                style: TextStyle(
                  color: color ?? ThemeUtils.defaultColor,
                  fontSize: suSetSp(18.0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: suSetSp(6.0)),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: suSetSp(18.0),
                color: color ?? ThemeUtils.defaultColor,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        showDialog<Null>(
          context: context,
          builder: (BuildContext context) =>
              AnnouncementDialog(Configs.announcements[0]),
        );
      },
    );
  }
}
