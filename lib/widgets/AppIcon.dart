import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';

class AppIcon extends StatelessWidget {
  final WebApp app;
  final double size;

  const AppIcon({
    Key key,
    @required this.app,
    this.size = 60.0,
  }) : super(key: key);

  final basePath = "assets/icons/appCenter";

  Future<Widget> loadAsset() async {
    final assetPath = "$basePath/${app.code}-${app.name}.svg";
    try {
      final _ = await rootBundle.load(assetPath);
      return SvgPicture.asset(
        assetPath,
        width: suSetWidth(size),
        height: suSetHeight(size),
      );
    } catch (e) {
      return ExtendedImage.network(
        oldIconUrl,
        width: suSetWidth(size),
        fit: BoxFit.fill,
      );
    }
  }

  String get oldIconUrl => "${API.webAppIcons}appid=${app.id}&code=${app.code}";

  @override
  Widget build(BuildContext context) {
    return !currentUser.isTeacher || Configs.newAppCenterIcon
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
            child: Center(
              child: ExtendedImage.network(oldIconUrl, fit: BoxFit.fill),
            ),
          );
  }
}
