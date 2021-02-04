///
/// [Author] Alex (https://github.com/AlexV525)
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
      (int index) => getSectionColumn(
        context,
        WebApp.category.keys.elementAt(index),
      ),
    );
    return Column(
      children: <Widget>[
        commonAppsSection(context),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.w,
            ).copyWith(
              bottom: Screens.bottomSafeHeight + 8.w,
            ),
            itemCount: _list.length,
            itemBuilder: (BuildContext _, int index) => _list[index],
          ),
        ),
      ],
    );
  }

  Widget editingButton(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (_, WebAppsProvider provider, __) {
        final bool isEditing = provider.isEditingCommonApps;
        return GestureDetector(
          onTap: () {
            if (isEditing) {
              provider.saveCommonApps();
            }
            provider.isEditingCommonApps = !isEditing;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SvgPicture.asset(
                isEditing
                    ? R.ASSETS_ICONS_APP_CENTER_EDIT_DONE_SVG
                    : R.ASSETS_ICONS_APP_CENTER_EDIT_SVG,
                width: 20.w,
                height: 20.w,
                color: context.textTheme.bodyText2.color,
              ),
              Gap(10.w),
              Text(isEditing ? '完成' : '编辑'),
            ],
          ),
        );
      },
    );
  }

  /// Section widget for common apps.
  /// 常用应用的区域部件
  Widget commonAppsSection(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (BuildContext _, WebAppsProvider provider, Widget __) {
        final bool isEditing = provider.isEditingCommonApps;
        return DefaultTextStyle.merge(
          style: TextStyle(height: 1.2, fontSize: 20.sp),
          child: Container(
            height: 86.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.w,
                  color: context.theme.dividerColor,
                ),
              ),
              color: context.theme.colorScheme.surface,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 96.w,
                  alignment: AlignmentDirectional.centerStart,
                  child: const Text('应用捷径'),
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: Builder(
                      builder: (BuildContext context) {
                        if (provider.commonWebApps.isEmpty) {
                          return Center(
                            child: Text(
                              isEditing ? '点击下方按钮以增删捷径' : '点击编辑以进行调整',
                              style: context.textTheme.caption.copyWith(
                                height: 1.2,
                                fontSize: 16.sp,
                              ),
                            ),
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List<Widget>.generate(
                            provider.commonWebApps.length,
                            (int index) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.w),
                                child: WebAppIcon(
                                  app: provider.commonWebApps.elementAt(index),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: 96.w,
                  alignment: AlignmentDirectional.centerEnd,
                  child: editingButton(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 应用部件
  Widget appWidget(
    BuildContext context,
    WebApp webApp, {
    bool needIndicator = true,
  }) {
    return Consumer<WebAppsProvider>(
      builder: (_, WebAppsProvider provider, Widget child) {
        return GestureDetector(
          child: Stack(
            children: <Widget>[
              child,
              appEditIndicator(context, provider, webApp, needIndicator),
            ],
          ),
          onTap: () {
            final bool isCommon = provider.commonWebApps.contains(webApp);
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
                    launch(webApp.replacedUrl, forceSafariVC: false);
                  }
                }
              : null,
        );
      },
      child: Positioned.fill(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(child: Center(child: WebAppIcon(app: webApp, size: 72.0))),
            Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child: Text(
                webApp.name,
                style: context.textTheme.bodyText2.copyWith(
                  height: 1.2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appEditIndicator(
    BuildContext context,
    WebAppsProvider provider,
    WebApp webApp,
    bool needIndicator,
  ) {
    final bool isCommon = provider.commonWebApps.contains(webApp);
    final bool isEditing = provider.isEditingCommonApps;
    return PositionedDirectional(
      bottom: 45.w,
      end: 20.w,
      child: isEditing
          ? Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: context.theme.canvasColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  isCommon
                      ? R.ASSETS_ICONS_APP_CENTER_REMOVE_SVG
                      : R.ASSETS_ICONS_APP_CENTER_ADD_SVG,
                  color: context.iconTheme.color,
                  width: 12.w,
                  height: 12.w,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// 分类列表组件
  Widget getSectionColumn(BuildContext context, String name) {
    return Selector<WebAppsProvider, Map<String, Set<WebApp>>>(
      selector: (_, WebAppsProvider p) => p.appCategoriesList,
      builder: (_, Map<String, Set<WebApp>> appCategoriesList, __) {
        final Set<WebApp> list = appCategoriesList[name];
        if (list?.isNotEmpty ?? false) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.w),
            padding: EdgeInsets.symmetric(vertical: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              color: context.theme.colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 30.w,
                    top: 10.h,
                    bottom: 10.h,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      WebApp.category[name],
                      style: context.textTheme.bodyText2.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            ),
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
    return Selector<WebAppsProvider, bool>(
      selector: (BuildContext _, WebAppsProvider provider) =>
          provider.isEditingCommonApps,
      builder: (BuildContext _, bool isEditingCommonApps, Widget __) {
        return WillPopScope(
          onWillPop: () {
            if (isEditingCommonApps) {
              context.read<WebAppsProvider>().saveCommonApps();
              context.read<WebAppsProvider>().isEditingCommonApps =
                  !isEditingCommonApps;
            }
            return Future<bool>.value(!isEditingCommonApps);
          },
          child: Scaffold(
            backgroundColor: Color.lerp(
              context.theme.canvasColor,
              context.theme.colorScheme.surface,
              0.5,
            ),
            body: FixedAppBarWrapper(
              appBar: const FixedAppBar(title: Text('应用中心')),
              body: fetching
                  ? const Center(
                      child: LoadMoreSpinningIcon(isRefreshing: true),
                    )
                  : categoryListView(context),
            ),
          ),
        );
      },
    );
  }
}
