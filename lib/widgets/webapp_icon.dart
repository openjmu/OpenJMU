import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

class WebAppIcon extends StatelessWidget {
  const WebAppIcon({
    Key key,
    @required this.app,
    this.size = 60.0,
  }) : super(key: key);

  final WebApp app;
  final double size;

  double get oldIconSize => size / 1.5;

  String get iconPath =>
      'assets/icons/app-center/apps/${app.appId}-${app.code}.svg';

  String get oldIconUrl => '${API.webAppIcons}'
      'appid=${app.appId}'
      '&code=${app.code}';

  Future<Widget> loadAsset() async {
    try {
      await rootBundle.load(iconPath);
      return SvgPicture.asset(
        iconPath,
        width: size.w,
        height: size.w,
      );
    } catch (e) {
      trueDebugPrint(
        'Error when load ${app.name}\'s icon: $e.\nLoading fallback icon...',
      );
      return ExtendedImage.network(
        oldIconUrl,
        fit: BoxFit.fill,
        width: oldIconSize.w,
        height: oldIconSize.w,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, bool>(
      selector: (_, SettingsProvider provider) => provider.newAppCenterIcon,
      builder: (_, bool newAppCenterIcon, __) {
        final bool shouldUseNew =
            !(currentUser?.isTeacher ?? false) || newAppCenterIcon;
        return shouldUseNew
            ? FutureBuilder<Widget>(
                initialData: const SizedBox.shrink(),
                future: loadAsset(),
                builder: (_, AsyncSnapshot<Widget> snapshot) =>
                    SizedBox.fromSize(
                  size: Size.square(size.w),
                  child: Center(child: snapshot.data),
                ),
              )
            : SizedBox.fromSize(
                size: Size.square(size.w),
                child: Center(
                  child: ExtendedImage.network(
                    oldIconUrl,
                    fit: BoxFit.fill,
                    width: oldIconSize.w,
                    height: oldIconSize.w,
                  ),
                ),
              );
      },
    );
  }
}
