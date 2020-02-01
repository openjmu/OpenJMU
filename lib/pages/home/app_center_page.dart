///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-07 19:39
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/webapp_icon.dart';

class AppCenterPage extends StatelessWidget {
  final GlobalKey refreshIndicatorKey;
  final ScrollController scrollController;

  AppCenterPage({
    this.refreshIndicatorKey,
    this.scrollController,
  });

  Widget categoryListView(context, WebAppsProvider provider) {
    final _list = <Widget>[];
    WebApp.category.forEach((name, value) {
      _list.add(getSectionColumn(context, provider, name));
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
          WebAppIcon(app: webApp, size: 90.0),
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
        navigatorState.pushNamed(
          Routes.OPENJMU_INAPPBROWSER,
          arguments: {"url": webApp.replacedUrl, "title": webApp.name, "app": webApp},
        );
      },
    );
  }

  Widget getSectionColumn(context, WebAppsProvider provider, String name) {
    final list = provider.appCategoriesList[name];
    if (list.isNotEmpty) {
      return Container(
        margin: EdgeInsets.all(suSetWidth(12.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: suSetHeight(12.0)),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).canvasColor),
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
              itemCount: list.length,
              itemBuilder: (context, index) {
                final _rows = (list.length / 3).ceil();
                final showBottom = ((index + 1) / 3).ceil() != _rows;
                final showRight = ((index + 1) / 3).ceil() != (index + 1) ~/ 3;
                Widget _w = DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: showBottom
                          ? BorderSide(color: Theme.of(context).canvasColor)
                          : BorderSide.none,
                      right: showRight
                          ? BorderSide(color: Theme.of(context).canvasColor)
                          : BorderSide.none,
                    ),
                  ),
                  child: getWebAppButton(context, list.elementAt(index)),
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
            ? SpinKitWidget()
            : RefreshIndicator(
                key: refreshIndicatorKey,
                child: categoryListView(context, provider),
                onRefresh: provider.updateApps,
              );
      },
    );
  }
}
