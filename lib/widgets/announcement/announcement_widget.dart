import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({
    Key key,
    this.contentColor,
    this.backgroundColor,
    this.gap,
    this.radius,
    this.canClose = false,
  }) : super(key: key);

  final Color contentColor;
  final Color backgroundColor;
  final double gap;
  final double radius;
  final bool canClose;

  IconThemeData get iconTheme => IconThemeData(
        color: contentColor ?? currentThemeColor,
        size: suSetWidth(26.0),
      );

  Widget title(SettingsProvider provider) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: suSetWidth(6.0)),
        child: Text(
          '  ${provider.announcements[0]['title']}',
          style: TextStyle(
            color: contentColor ?? defaultLightColor,
            fontSize: suSetSp(20.0),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget actionIcon(BuildContext context, SettingsProvider provider) {
    return IconTheme(
      data: iconTheme,
      child: canClose
          ? GestureDetector(
              onTap: () {
                provider.announcementsUserEnabled = false;
              },
              child: IconTheme(data: iconTheme, child: Icon(Icons.close)),
            )
          : SvgPicture.asset(
              R.ASSETS_ICONS_ARROW_RIGHT_SVG,
              color: iconTheme.color,
              width: iconTheme.size,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, SettingsProvider provider, __) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(gap ?? 15.0),
              vertical: suSetHeight(10.0),
            ),
            decoration: BoxDecoration(
              borderRadius: radius != null
                  ? BorderRadius.circular(suSetWidth(radius))
                  : null,
              color: (backgroundColor ?? defaultLightColor).withAlpha(0x44),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.notifications_active,
                    color: iconTheme.color, size: iconTheme.size),
                title(provider),
                actionIcon(context, provider),
              ],
            ),
          ),
          onTap: () {
            final Map<String, dynamic> data =
                provider.announcements[0].cast<String, dynamic>();
            ConfirmationDialog.show(context,
                title: data['title'] as String,
                content: data['content'] as String,
                cancelLabel: '朕已阅');
          },
        );
      },
    );
  }
}
