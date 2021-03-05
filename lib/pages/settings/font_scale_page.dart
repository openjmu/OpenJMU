import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://font-scale', routeName: '更改字号页')
class FontScalePage extends StatefulWidget {
  @override
  _FontScalePageState createState() => _FontScalePageState();
}

class _FontScalePageState extends State<FontScalePage> with RouteAware {
  final double baseFontSize = 24.0;
  SettingsProvider settingsProvider;

  List<double> scaleRange;
  double scale;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    );
    scaleRange = settingsProvider.fontScaleRange;
    scale = settingsProvider.fontScale;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Instances.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    Instances.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    HiveFieldUtils.setFontScale(scale);
  }

  Widget _textIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: suSetSp(baseFontSize, scale: scaleRange[0]),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '标准',
                style: TextStyle(
                  fontSize: suSetSp(
                    baseFontSize,
                    scale: (scaleRange[0] + scaleRange[1]) / 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: suSetSp(baseFontSize, scale: scaleRange[1]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: maxBorderRadius,
        color: context.themeColor,
      ),
      child: SliderTheme(
        data: SliderThemeData(
          thumbColor: context.surfaceColor,
          activeTickMarkColor: context.surfaceColor.withOpacity(0.5),
          inactiveTickMarkColor: context.surfaceColor.withOpacity(0.5),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 20.w),
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 12.w,
            elevation: 0,
            pressedElevation: 0,
          ),
          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.w),
        ),
        child: Slider(
          min: scaleRange[0],
          max: scaleRange[1],
          divisions: 6,
          value: scale,
          onChanged: (double value) {
            setState(() {
              scale = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: const FixedAppBar(title: Text('设置字体大小')),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                '调整字体大小以获得最佳阅读体验',
                style: context.textTheme.caption.copyWith(fontSize: 20.sp),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '这是一行示例文字\nThis is a sample sentence',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: suSetSp(baseFontSize, scale: scale),
                  ),
                ),
              ),
            ),
            const LineDivider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 25.w),
              color: context.surfaceColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _textIndicator(context),
                  _slider(context),
                  SizedBox(height: Screens.bottomSafeHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
