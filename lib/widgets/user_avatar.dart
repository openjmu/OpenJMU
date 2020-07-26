///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 18:15
///
import 'package:flutter/material.dart';

import 'package:openjmu/openjmu_route_helper.dart';
import 'package:openjmu/constants/constants.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key key,
    this.uid,
    this.size = 48.0,
    this.timestamp,
    this.radius,
    this.canJump = true,
  })  : assert(radius == null || (radius != null && radius > 0.0)),
        super(key: key);

  final double size;
  final int uid;
  final int timestamp;
  final double radius;
  final bool canJump;

  @override
  Widget build(BuildContext context) {
    final int _uid = uid ?? currentUser.uid;
    return SizedBox.fromSize(
      size: Size.square(size.w),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: radius != null
              ? BorderRadius.circular(suSetWidth(radius))
              : maxBorderRadius,
          child: FadeInImage(
            fadeInDuration: 150.milliseconds,
            placeholder: AssetImage(R.ASSETS_AVATAR_PLACEHOLDER_PNG),
            image: UserAPI.getAvatarProvider(uid: _uid),
          ),
        ),
        onTap: canJump
            ? () {
                final RouteSettings _routeSettings =
                    ModalRoute.of(context).settings;
                final Map<String, dynamic> _routeArguments = <String, dynamic>{
                  'uid': _uid,
                };
                if (_routeSettings is FFRouteSettings) {
                  if (_routeSettings.name != Routes.openjmuUserPage ||
                      _routeSettings.arguments.toString() !=
                          _routeArguments.toString()) {
                    navigatorState.pushNamed(
                      Routes.openjmuUserPage,
                      arguments: _routeArguments,
                    );
                  }
                } else {
                  navigatorState.pushNamed(
                    Routes.openjmuUserPage,
                    arguments: _routeArguments,
                  );
                }
              }
            : null,
      ),
    );
  }
}
