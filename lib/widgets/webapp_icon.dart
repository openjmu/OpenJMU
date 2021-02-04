import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

class WebAppIcon extends StatelessWidget {
  const WebAppIcon({
    Key key,
    @required this.app,
    this.size,
  }) : super(key: key);

  final WebApp app;
  final double size;

  double get oldIconSize => size != null ? size / 1.375 : null;

  String get iconPath => 'assets/icons/app-center/apps/'
      '${app.appId}-${app.code}.svg';

  String get oldIconUrl => '${API.webAppIcons}'
      'appid=${app.appId}'
      '&code=${app.code}';

  Future<bool> get exist async {
    try {
      await rootBundle.load(iconPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Widget> loadAsset() async {
    if (await exist) {
      return SvgPicture.asset(
        iconPath,
        width: size?.w,
        height: size?.w,
      );
    } else {
      LogUtils.e(
        'Error when load '
        '${app.name} (${app.appId}-${app.code})'
        '\'s icon.',
      );
      return ExtendedImage.network(
        oldIconUrl,
        fit: BoxFit.fill,
        width: oldIconSize?.w,
        height: oldIconSize?.w,
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
        Widget child = shouldUseNew
            ? FutureBuilder<Widget>(
                initialData: const SizedBox.shrink(),
                future: loadAsset(),
                builder: (_, AsyncSnapshot<Widget> snapshot) => snapshot.data,
              )
            : ExtendedImage.network(
                oldIconUrl,
                fit: BoxFit.fill,
                width: oldIconSize?.w,
                height: oldIconSize?.w,
              );
        if (size != null) {
          child = SizedBox.fromSize(
            size: Size.square(size.w),
            child: Center(child: child),
          );
        }
        return child;
      },
    );
  }
}
