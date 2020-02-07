import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

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
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, List>(
      selector: (_, provider) => provider.announcements,
      builder: (_, announcements, __) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(gap ?? 15.0),
              vertical: suSetHeight(10.0),
            ),
            decoration: BoxDecoration(
              borderRadius: radius != null ? BorderRadius.circular(suSetWidth(radius)) : null,
              color: (color ?? defaultColor).withAlpha(0x44),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.notifications_active, size: suSetWidth(24.0), color: currentThemeColor),
                Expanded(
                  child: Text(
                    '  ${announcements[0]['title']}',
                    style: TextStyle(
                      color: color ?? defaultColor,
                      fontSize: suSetSp(21.0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: suSetWidth(6.0)),
                  child: SvgPicture.asset(
                    'assets/icons/arrow-right.svg',
                    width: suSetWidth(24.0),
                    color: currentThemeColor,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            final data = announcements[0];
            ConfirmationDialog.show(context, title: data['title'], content: data['content']);
          },
        );
      },
    );
  }
}
