///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-07 19:39
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://app-center-page', routeName: '应用中心')
class AppCenterPage extends StatelessWidget {
  /// 整体列表组件
  Widget categoryListView(BuildContext context) {
    final List<Widget> _list = <Widget>[];
    WebApp.category.forEach((String name, String value) {
      _list.add(getSectionColumn(context, name));
    });
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
        itemCount: _list.length,
        itemBuilder: (BuildContext _, int index) => _list[index],
      ),
    );
  }

  /// 应用部件
  Widget appWidget(BuildContext context, WebApp webApp) {
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WebAppIcon(app: webApp, size: 64.0),
          Text(
            webApp.name,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.normal,
                ),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
      onPressed: () {
        API.launchWeb(url: webApp.replacedUrl, app: webApp);
      },
      onLongPress: () async {
        final bool confirm = await ConfirmationDialog.show(
          context,
          title: '打开应用',
          content: '是否使用浏览器打开该应用?',
          showConfirm: true,
        );
        if (confirm) {
          unawaited(launch(webApp.replacedUrl, forceSafariVC: false));
        }
      },
    );
  }

  /// 分类列表组件
  Widget getSectionColumn(context, String name) {
    return Selector<WebAppsProvider, Map<String, Set<WebApp>>>(
      selector: (BuildContext _, WebAppsProvider provider) =>
          provider.appCategoriesList,
      builder: (BuildContext _, Map<String, Set<WebApp>> appCategoriesList,
          Widget __,) {
        final Set<WebApp> list = appCategoriesList[name];
        if (list?.isNotEmpty ?? false) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.0.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).canvasColor),
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    WebApp.category[name],
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 20.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: list.length,
                itemBuilder: (BuildContext _, int index) =>
                    appWidget(context, list.elementAt(index)),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: Text('应用中心'),
        ),
        body: Selector<WebAppsProvider, bool>(
          selector: (BuildContext _, WebAppsProvider provider) => provider.fetching,
          builder: (BuildContext _, bool fetching, Widget __) {
            return fetching ? SpinKitWidget() : categoryListView(context);
          },
        ),
      ),
    );
  }
}
