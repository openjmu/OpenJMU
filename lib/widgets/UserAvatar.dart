///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 18:15
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/OpenJMU_route_helper.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final int uid;
  final int timestamp;

  const UserAvatar({
    Key key,
    @required this.uid,
    this.size = 48.0,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: suSetWidth(size),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetWidth(size)),
          child: FadeInImage(
            fadeInDuration: const Duration(milliseconds: 100),
            placeholder: AssetImage("assets/avatar_placeholder.png"),
            image: UserAPI.getAvatarProvider(
              uid: uid ?? UserAPI.currentUser.uid,
            ),
          ),
        ),
        onTap: () {
          final settings = ModalRoute.of(context).settings as FFRouteSettings;
          if (settings.name != "openjmu://user" ||
              settings.arguments.toString() !=
                  {"uid": uid ?? UserAPI.currentUser.uid}.toString()) {
            UserPage.jump(uid);
          }
        },
      ),
    );
  }
}
