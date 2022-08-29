import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openjmu/constants/constants.dart';

class WebAppIcon extends StatelessWidget {
  const WebAppIcon({super.key, required this.app, this.size});

  final WebApp app;
  final double? size;

  double? get oldIconSize => size != null ? size! / 1.375 : null;

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
      return SvgPicture.asset(iconPath, width: size?.w, height: size?.w);
    }
    LogUtil.e(
      "Error when load ${app.name} (${app.appId}-${app.code}) 's icon.\n"
      'Fallback the original icon...',
    );
    return ExtendedImage.network(
      oldIconUrl,
      fit: BoxFit.fill,
      width: oldIconSize?.w,
      height: oldIconSize?.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, bool>(
      selector: (_, SettingsProvider p) => p.newAppCenterIcon,
      builder: (_, bool value, __) {
        final bool shouldUseNew = !currentUser.isTeacher || value;
        Widget child;
        if (shouldUseNew) {
          child = FutureBuilder<Widget>(
            initialData: const SizedBox.shrink(),
            future: loadAsset(),
            builder: (_, AsyncSnapshot<Widget> data) => data.data!,
          );
        } else {
          child = ExtendedImage.network(
            oldIconUrl,
            fit: BoxFit.fill,
            width: oldIconSize?.w,
            height: oldIconSize?.w,
          );
        }
        if (size != null) {
          child = SizedBox.fromSize(
            size: Size.square(size!.w),
            child: Center(child: child),
          );
        }
        return child;
      },
    );
  }
}
