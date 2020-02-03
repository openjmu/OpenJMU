///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-31 22:29
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://changelog-page", routeName: "版本履历")
class ChangeLogPage extends StatefulWidget {
  @override
  _ChangeLogPageState createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage> {
  final _pageController = PageController();
  double _currentPage = 0.0;

  List changeLogs;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadChangelog();
  }

  Future<void> loadChangelog() async {
    try {
      final changelog = await rootBundle.loadString('assets/changelog.json');
      changeLogs = (jsonDecode(changelog) as List).cast<Map>();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed when loading changelog: $e');
      error = true;
      if (mounted) setState(() {});
    }
  }

  Widget get timelineIndicator => Container(
        margin: EdgeInsets.only(right: suSetWidth(40.0)),
        width: suSetWidth(6.0),
        color: currentThemeColor,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              top: suSetHeight(38.0),
              left: -suSetWidth(7.0),
              child: Container(
                width: suSetWidth(20.0),
                height: suSetWidth(20.0),
                decoration: BoxDecoration(shape: BoxShape.circle, color: currentThemeColor),
              ),
            ),
          ],
        ),
      );

  Widget _logLine(bool left) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: suSetHeight(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(left ? 0 : 999),
            right: Radius.circular(!left ? 0 : 999),
          ),
          color: currentThemeColor,
        ),
      ),
    );
  }

  Widget _logVersion(ChangeLog log) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: suSetWidth(40.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              versionInfo(log),
              buildNumberInfo(log),
            ],
          ),
          SizedBox(height: suSetHeight(12.0)),
          dateInfo(log),
        ],
      ),
    );
  }

  Widget logWidget(
    int index,
    ChangeLog log, {
    double parallaxOffset,
  }) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: Screens.width,
            height: Screens.height / 6,
            child: Row(
              children: <Widget>[
                index == 0 ? Spacer() : _logLine(true),
                _logVersion(log),
                _logLine(false),
              ],
            ),
          ),
          Expanded(
            child: Transform(
              transform: Matrix4.translationValues(parallaxOffset, 0.0, 0.0),
              child: Container(
                margin: EdgeInsets.only(
                  left: suSetWidth(40.0),
                  right: suSetWidth(40.0),
                  bottom: suSetHeight(60.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(suSetWidth(15.0)),
                  color: Theme.of(context).canvasColor,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(suSetWidth(20.0)),
                  physics: const BouncingScrollPhysics(),
                  child: sectionWidget(log.sections),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget versionInfo(ChangeLog log) {
    return Text(
      '${log.version} ',
      style: Theme.of(context).textTheme.title.copyWith(fontSize: suSetSp(40.0)),
    );
  }

  Widget buildNumberInfo(ChangeLog log) {
    return Text(
      '(${log.buildNumber})',
      style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget dateInfo(ChangeLog log) {
    return Text(
      '${log.date}',
      style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget sectionWidget(Map<String, dynamic> sections) {
    return Text.rich(
      TextSpan(
        children: List<TextSpan>.generate(
          sections.keys.length,
          (i) => contentColumn(sections, i),
        ),
      ),
      style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  TextSpan contentColumn(Map<String, dynamic> sections, int index) {
    final name = sections.keys.elementAt(index);
    return TextSpan(
      children: List<TextSpan>.generate(
        sections[name].length + 1,
        (j) => j == 0
            ? TextSpan(
                text: '[$name]\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : TextSpan(text: '·  ${sections[name][j - 1]}\n'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Text(
              '版本履历',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: suSetSp(23.0),
                  ),
            ),
            centerTitle: true,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: 1.seconds,
              child: changeLogs != null
                  ? LayoutBuilder(
                      builder: (context, constraints) => NotificationListener(
                        onNotification: (ScrollNotification note) {
                          setState(() {
                            _currentPage = _pageController.page;
                          });
                          return true;
                        },
                        child: PageView.custom(
                          controller: _pageController,
                          childrenDelegate: SliverChildBuilderDelegate(
                            (context, index) => logWidget(
                              index,
                              ChangeLog.fromJson(changeLogs[index]),
                              parallaxOffset: constraints.maxWidth / 2.0 * (index - _currentPage),
                            ),
                            childCount: changeLogs.length,
                          ),
                        ),
                      ),
                    )
                  : SpinKitWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangeLog {
  String version;
  int buildNumber;
  String date;
  Map<String, dynamic> sections;

  ChangeLog({this.version, this.buildNumber, this.date, this.sections});

  ChangeLog.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    buildNumber = json['buildNumber'];
    date = json['date'];
    sections = json['sections'];
  }

  Map<String, dynamic> toJson() {
    return {'version': version, 'buildNumber': buildNumber, 'date': date, 'sections': sections};
  }

  @override
  String toString() {
    return 'ChangeLog ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
