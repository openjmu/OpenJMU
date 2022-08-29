///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-23 18:15
///
import 'package:extended_image/extended_image.dart'
    hide ExtendedNetworkImageProvider;

// ignore: implementation_imports
import 'package:extended_image_library/src/_network_image_io.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    this.size = 48,
    this.uid,
    this.radius,
    this.canJump = true,
    this.isSysAvatar = false,
  }) : assert(radius == null || radius > 0);

  final double size;
  final String? uid;
  final double? radius;
  final bool canJump;
  final bool isSysAvatar;

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late final String _uid = widget.uid ?? currentUser.uid;
  late final ExtendedNetworkImageProvider provider =
      UserAPI.getAvatarProvider(uid: _uid);

  String? _stringData;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<UserAvatarUpdateEvent>().listen((_) {
      if (mounted && _uid == currentUser.uid) {
        setState(() {});
      }
    });
  }

  void jump(BuildContext context) {
    final RouteSettings? _routeSettings = ModalRoute.of(context)?.settings;
    final Map<String, dynamic> _routeArguments = Routes.openjmuUserPage.d(
      uid: _uid,
    );
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: widget.radius != null
            ? BorderRadius.circular(widget.radius!.w)
            : maxBorderRadius,
        color: context.theme.dividerColor,
      ),
      child: SvgPicture.asset(
        R.ASSETS_PLACEHOLDERS_AVATAR_SVG,
        width: widget.size.w * 0.7,
        color: context.textTheme.bodyText2?.color,
      ),
    );
  }

  Widget _realAvatar(BuildContext context) {
    return ExtendedImage(
      borderRadius: widget.radius != null
          ? BorderRadius.circular(widget.radius!.w)
          : maxBorderRadius,
      shape: BoxShape.rectangle,
      image: provider,
      loadStateChanged: (ExtendedImageState state) {
        if (state.extendedImageLoadState == LoadState.completed) {
          _stringData ??= provider.rawImageData.toString();
          if (_stringData == Instances.defaultAvatarData) {
            return _defaultAvatar(context);
          }
          return null;
        }
        return _defaultAvatar(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(widget.size.w),
      child: GestureDetector(
        onTap: widget.canJump ? () => jump(context) : null,
        child:
            widget.isSysAvatar ? _defaultAvatar(context) : _realAvatar(context),
      ),
    );
  }
}
