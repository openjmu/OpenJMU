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
    final List<Widget> _list = List<Widget>.generate(
      WebApp.category.keys.length,
      (int index) {
        return getSectionColumn(context, WebApp.category.keys.elementAt(index));
      },
    );
    return Column(
      children: <Widget>[
        commonAppsSection(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
              itemCount: _list.length,
              itemBuilder: (BuildContext _, int index) => _list[index],
            ),
          ),
        ),
      ],
    );
  }

  /// Section widget for common apps.
  /// 常用应用的区域部件
  Widget commonAppsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: IntrinsicHeight(
        child: Column(
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
                  '常用应用',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: 20.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<WebAppsProvider>(
                builder: (BuildContext _, WebAppsProvider provider, Widget __) {
                  if (provider.commonWebApps.isEmpty) {
                    return SizedBox(
                      height:
                          (Screens.width - 40.0.w) / provider.maxCommonWebApps,
                      child: Center(
                        child: Text(
                          '快来添加你的常用应用吧~',
                          style: TextStyle(fontSize: 18.0.sp),
                        ),
                      ),
                    );
                  } else {
                    return Row(
                      children: <Widget>[
                        ...List.generate(
                          provider.commonWebApps.length,
                          (int index) {
                            final WebApp app =
                                provider.commonWebApps.elementAt(index);
                            return Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: appWidget(context, app, isCommon: true),
                              ),
                            );
                          },
                        ),
                        ...List.generate(
                          provider.maxCommonWebApps -
                              provider.commonWebApps.length,
                          (int index) {
                            return const Spacer();
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 应用部件
  Widget appWidget(
    BuildContext context,
    WebApp webApp, {
    bool isCommon = false,
  }) {
    return Consumer<WebAppsProvider>(
      builder: (BuildContext _, WebAppsProvider provider, Widget __) {
        return InkWell(
          splashFactory: InkSplash.splashFactory,
          borderRadius: BorderRadius.circular(15.0.w),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(child: WebAppIcon(app: webApp, size: 72.0)),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0.sp),
                      child: Text(
                        webApp.name,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.normal,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isEditingCommonApps)
                appEditIndicator(context, provider, webApp, isCommon: isCommon),
            ],
          ),
          onTap: () {
            if (provider.isEditingCommonApps) {
              if (isCommon) {
                provider.removeCommonApp(webApp);
              } else {
                provider.addCommonApp(webApp);
              }
            } else {
              API.launchWeb(url: webApp.replacedUrl, app: webApp);
            }
          },
          onLongPress: !provider.isEditingCommonApps
              ? () async {
                  final bool confirm = await ConfirmationDialog.show(
                    context,
                    title: '打开应用',
                    content: '是否使用浏览器打开该应用?',
                    showConfirm: true,
                  );
                  if (confirm) {
                    unawaited(launch(webApp.replacedUrl, forceSafariVC: false));
                  }
                }
              : null,
        );
      },
    );
  }

  Widget appEditIndicator(
    BuildContext context,
    WebAppsProvider provider,
    WebApp webApp, {
    bool isCommon = false,
  }) {
    return PositionedDirectional(
      top: 10.0.w,
      end: 10.0.w,
      child: !isCommon && provider.commonWebApps.contains(webApp)
          ? const SizedBox.shrink()
          : Container(
              padding: EdgeInsets.all(3.0.w),
              decoration: BoxDecoration(
                color: currentThemeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCommon ? Icons.close : Icons.add,
                color: Colors.white,
                size: 20.0.w,
              ),
            ),
    );
  }

  /// 分类列表组件
  Widget getSectionColumn(context, String name) {
    return Selector<WebAppsProvider, Map<String, Set<WebApp>>>(
      selector: (BuildContext _, WebAppsProvider provider) =>
          provider.appCategoriesList,
      builder: (
        BuildContext _,
        Map<String, Set<WebApp>> appCategoriesList,
        Widget __,
      ) {
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
                itemBuilder: (BuildContext _, int index) => appWidget(
                  context,
                  list.elementAt(index),
                ),
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
    final bool fetching = context.select<WebAppsProvider, bool>(
      (WebAppsProvider provider) => provider.fetching,
    );
//    HiveBoxes.webAppsCommonBox.delete(currentUser.uid);
    return WillPopScope(
      onWillPop: () {
        context.read<WebAppsProvider>().saveCommonApps();
        return Future.value(true);
      },
      child: Scaffold(
        body: FixedAppBarWrapper(
          appBar: FixedAppBar(
            title: Text('应用中心'),
            actions: <Widget>[
              Consumer<WebAppsProvider>(
                builder: (BuildContext _, WebAppsProvider provider, Widget __) {
                  return FlatButton(
                    child: Text(
                      provider.isEditingCommonApps ? '完成' : '编辑',
                    ),
                    onPressed: () {
                      provider.isEditingCommonApps =
                          !provider.isEditingCommonApps;
                    },
                  );
                },
              ),
            ],
          ),
          body: fetching ? SpinKitWidget() : categoryListView(context),
        ),
      ),
    );
  }
}
