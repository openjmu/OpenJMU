import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class AnnouncementDialog extends StatefulWidget {
    final Map<String, dynamic> announcement;

    AnnouncementDialog(this.announcement, {Key key}) : super(key: key);

    @override
    _AnnouncementDialogState createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<AnnouncementDialog> {
    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            backgroundColor: ThemeUtils.currentThemeColor,
            title: Text(
                "${widget.announcement['title']}",
                style: TextStyle(
                    fontSize: Constants.suSetSp(22.0),
                    color: Colors.white,
                ),
            ),
            content: Wrap(
                children: <Widget>[
                    Text(
                        "${widget.announcement['content']}",
                        style: TextStyle(
                            fontSize: Constants.suSetSp(18.0),
                            color: Colors.white,
                        ),
                    ),
                ],
            ),
        );
    }
}
