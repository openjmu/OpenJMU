///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 18:15
///
import 'package:flutter/material.dart';

import 'package:openjmu/openjmu_route_helper.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/user/user_page.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final int uid;
  final int timestamp;
  final bool canJump;

  const UserAvatar({
    Key key,
    this.uid,
    this.size = 48.0,
    this.timestamp,
    this.canJump = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _uid = uid ?? UserAPI.currentUser.uid;
    return SizedBox(
      width: suSetWidth(size),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetWidth(size)),
          child: FadeInImage(
            fadeInDuration: const Duration(milliseconds: 100),
            placeholder: AssetImage("assets/avatar_placeholder.png"),
            image: UserAPI.getAvatarProvider(uid: _uid),
          ),
        ),
        onTap: canJump
            ? () {
                final _routeSettings = ModalRoute.of(context).settings;
                if (_routeSettings is FFRouteSettings) {
                  final settings = ModalRoute.of(context).settings as FFRouteSettings;
                  if (settings.name != "openjmu://user" ||
                      settings.arguments.toString() != {"uid": _uid}.toString()) {
                    UserPage.jump(_uid);
                  }
                } else {
                  UserPage.jump(_uid);
                }
              }
            : null,
      ),
    );
  }
}
