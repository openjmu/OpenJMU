///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/10/21 10:11 PM
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

class NoNetworkPage extends StatelessWidget {
  const NoNetworkPage({Key key}) : super(key: key);

  Widget get logo {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.w),
      child: SvgPicture.asset(
        R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
        width: Screens.width / 3,
        color: currentThemeColor,
      ),
    );
  }

  Widget loginWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          R.ASSETS_PLACEHOLDERS_NO_NETWORK_SVG,
          width: 36.w,
          color: context.textTheme.caption.color.withOpacity(0.5),
        ),
        Gap(15.w),
        DefaultTextStyle.merge(
          style: TextStyle(
            color: context.textTheme.caption.color.withOpacity(0.5),
            height: 1.2,
            fontSize: 18.sp,
          ),
          child: const Text('网络未连接'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: currentIsDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Material(
        color: context.theme.colorScheme.surface,
        child: SizedBox(
          width: Screens.width,
          height: Screens.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logo,
              AnimatedContainer(
                duration: 200.milliseconds,
                margin: EdgeInsets.only(top: 10.w),
                width: Screens.width,
                height: 50.w,
                child: loginWidget(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
