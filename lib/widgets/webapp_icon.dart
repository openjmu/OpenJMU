import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

class WebAppIcon extends StatelessWidget {
  final WebApp app;
  final double size;

  const WebAppIcon({
    Key key,
    @required this.app,
    this.size = 60.0,
  }) : super(key: key);

  Future<Widget> loadAsset() async {
    try {
      final _ = await rootBundle.load(iconPath);
      return SvgPicture.asset(iconPath, width: suSetWidth(size), height: suSetWidth(size));
    } catch (e) {
      debugPrint('Error when load webapp icon: $e.\nLoading fallback icon...');
      return ExtendedImage.network(
        oldIconUrl,
        width: suSetWidth(size),
        height: suSetWidth(size),
        fit: BoxFit.fill,
      );
    }
  }

  String get iconPath => 'assets/icons/appCenter/${app.code}-${app.name}.svg';

  String get oldIconUrl => '${API.webAppIcons}appid=${app.appId}&code=${app.code}';

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, bool>(
      selector: (_, provider) => provider.newAppCenterIcon,
      builder: (_, newAppCenterIcon, __) {
        return !currentUser.isTeacher || newAppCenterIcon
            ? FutureBuilder(
                initialData: SizedBox(),
                future: loadAsset(),
                builder: (_, snapshot) => SizedBox(
                  width: suSetWidth(size),
                  height: suSetHeight(size),
                  child: Center(child: snapshot.data),
                ),
              )
            : SizedBox(
                width: suSetWidth(size / 1.2),
                height: suSetHeight(size / 1.2),
                child: Center(child: ExtendedImage.network(oldIconUrl, fit: BoxFit.fill)),
              );
      },
    );
  }
}
