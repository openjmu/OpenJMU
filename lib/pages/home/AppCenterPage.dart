///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-07 19:39
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppIcon.dart';

class AppCenterPage extends StatelessWidget {
  final GlobalKey refreshIndicatorKey;
  final ScrollController scrollController;

  AppCenterPage({
    this.refreshIndicatorKey,
    this.scrollController,
  });

  final webAppWidgetList = Map<String, List<Widget>>();

  Widget categoryListView(context, WebAppsProvider provider) {
    final apps = provider.apps;
    for (final app in apps) {
      if (app.url?.isNotEmpty ?? false) {
        if (webAppWidgetList[app.menuType] == null) {
          webAppWidgetList[app.menuType] = [];
        }
        webAppWidgetList[app.menuType].add(getWebAppButton(context, app));
      }
    }
    final _list = <Widget>[];
    WebApp.category.forEach((name, value) {
      _list.add(getSectionColumn(context, name));
    });
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: scrollController,
      itemCount: _list.length,
      itemBuilder: (BuildContext context, index) => _list[index],
    );
  }

  Widget getWebAppButton(context, WebApp webApp) {
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(app: webApp, size: 90.0),
          Text(
            webApp.name,
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontSize: suSetSp(20.0),
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
      ),
      onPressed: () {
        navigatorState.pushNamed("openjmu://webpage", arguments: {
          "url": webApp.replacedUrl,
          "title": webApp.name,
          "app": webApp,
        });
      },
    );
  }

  Widget getSectionColumn(context, name) {
    if (webAppWidgetList[name] != null) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: suSetHeight(12.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  WebApp.category[name],
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: suSetSp(22.0),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: webAppWidgetList[name].length,
              itemBuilder: (context, index) {
                final int _rows = (webAppWidgetList[name].length / 3).ceil();
                final bool showBottom = ((index + 1) / 3).ceil() != _rows;
                final bool showRight =
                    ((index + 1) / 3).ceil() != (index + 1) ~/ 3;
                Widget _w = webAppWidgetList[name][index];
                _w = DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: showBottom
                          ? BorderSide(
                              color: Theme.of(context).canvasColor,
                            )
                          : BorderSide.none,
                      right: showRight
                          ? BorderSide(
                              color: Theme.of(context).canvasColor,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: _w,
                );
                return _w;
              },
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (_, provider, __) {
        return provider.fetching
            ? Center(child: PlatformProgressIndicator())
            : RefreshIndicator(
                key: refreshIndicatorKey,
                child: categoryListView(context, provider),
                onRefresh: () async {
                  webAppWidgetList.clear();
                  await provider.updateApps();
                },
              );
      },
    );
  }
}
