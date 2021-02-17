///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-23 18:15
///
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

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
    this.isSysAvatar = false,
  })  : assert(radius == null || (radius != null && radius > 0.0)),
        super(key: key);

  final double size;
  final String uid;
  final int timestamp;
  final double radius;
  final bool canJump;
  final bool isSysAvatar;

  String get _uid => uid ?? currentUser.uid;

  void jump(BuildContext context) {
    final RouteSettings _routeSettings = ModalRoute.of(context).settings;
    final Map<String, dynamic> _routeArguments =
        Routes.openjmuUserPage.d(uid: _uid);

    if (_routeSettings is FFRouteSettings) {
      if (_routeSettings.name != Routes.openjmuUserPage.name ||
          _routeSettings.arguments.toString() != _routeArguments.toString()) {
        navigatorState.pushNamed(
          Routes.openjmuUserPage.name,
          arguments: _routeArguments,
        );
      }
    } else {
      navigatorState.pushNamed(
        Routes.openjmuUserPage.name,
        arguments: _routeArguments,
      );
    }
  }

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            radius != null ? BorderRadius.circular(radius.w) : maxBorderRadius,
        color: context.theme.dividerColor,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        R.ASSETS_PLACEHOLDERS_AVATAR_SVG,
        width: size.w * 0.7,
        color: context.textTheme.bodyText2.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size.w),
      child: GestureDetector(
        onTap: canJump ? () => jump(context) : null,
        child: isSysAvatar
            ? _defaultAvatar(context)
            : ExtendedImage(
                borderRadius: radius != null
                    ? BorderRadius.circular(radius.w)
                    : maxBorderRadius,
                shape: BoxShape.rectangle,
                image: UserAPI.getAvatarProvider(uid: _uid),
                loadStateChanged: (ExtendedImageState state) {
                  if (state.extendedImageLoadState == LoadState.completed) {
                    return null;
                  }
                  return _defaultAvatar(context);
                },
              ),
      ),
    );
  }
}
