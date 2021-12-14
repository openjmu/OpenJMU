import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({
    Key key,
    this.contentColor,
    this.backgroundColor,
    this.height,
    this.gap,
    this.radius,
    this.canClose = false,
  }) : super(key: key);

  final Color contentColor;
  final Color backgroundColor;
  final double height;
  final double gap;
  final double radius;
  final bool canClose;

  Color get adaptiveColor {
    if (contentColor != null) {
      return contentColor;
    }
    return adaptiveButtonColor(Colors.white70);
  }

  IconThemeData get iconTheme =>
      IconThemeData(color: adaptiveColor, size: 26.w);

  Widget title(SettingsProvider provider) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Text(
          '  ${provider.announcements[0]['title']}',
          style: TextStyle(color: adaptiveColor, fontSize: 20.sp),
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
          ? Tapper(
              onTap: () {
                provider.announcementsUserEnabled = false;
              },
              child: IconTheme(
                data: iconTheme,
                child: const Icon(Icons.close),
              ),
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
      builder: (BuildContext _, SettingsProvider provider, Widget __) {
        return Tapper(
          onTap: () {
            final Map<String, dynamic> data =
                provider.announcements[0].cast<String, dynamic>();
            ConfirmationDialog.show(
              context,
              title: data['title'] as String,
              content: data['content'] as String,
              showConfirm: true,
              showCancel: false,
            );
          },
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: (gap ?? 15.0).w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  radius != null ? BorderRadius.circular(radius.w) : null,
              color: backgroundColor ?? defaultLightColor,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active,
                  color: iconTheme.color,
                  size: iconTheme.size,
                ),
                title(provider),
                actionIcon(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }
}
