import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  Future<Widget> loadAsset(WebApp app) async {
    final String basePath = "assets/icons/appCenter";
    final String assetPath = "$basePath/${app.code}-${app.name}.svg";
    try {
      ByteData _ = await rootBundle.load(assetPath);
      return SvgPicture.asset(
        assetPath,
        width: suSetSp(size),
        height: suSetSp(size),
      );
    } catch (e) {
      final String imageUrl = "${API.webAppIcons}"
          "appid=${app.id}"
          "&code=${app.code}";
      return Image(
        image: CachedNetworkImageProvider(imageUrl,
            cacheManager: DefaultCacheManager()),
        fit: BoxFit.fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Configs.newAppCenterIcon
        ? FutureBuilder(
            initialData: SizedBox(),
            future: loadAsset(app),
            builder: (context, snapshot) {
              return SizedBox(
                width: suSetSp(size),
                height: suSetSp(size),
                child: Center(
                  child: snapshot.data,
                ),
              );
            },
          )
        : SizedBox(
            width: suSetSp(size),
            height: suSetSp(size),
            child: Center(
              child: Image(
                image: CachedNetworkImageProvider(
                  "${API.webAppIcons}"
                  "appid=${app.id}"
                  "&code=${app.code}",
                  cacheManager: DefaultCacheManager(),
                ),
                fit: BoxFit.fill,
              ),
            ),
          );
  }
}
