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
      (int index) {
        return getSectionColumn(context, WebApp.category.keys.elementAt(index));
      },
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      child: Column(
        children: <Widget>[
          commonAppsSection(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
              itemCount: _list.length,
              itemBuilder: (BuildContext _, int index) => _list[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget editingButton(BuildContext context) {
    return Expanded(
      child: Consumer<WebAppsProvider>(
        builder: (BuildContext _, WebAppsProvider provider, Widget __) {
          final bool isEditing = provider.isEditingCommonApps;
          return InkWell(
            splashFactory: InkSplash.splashFactory,
            onTap: () {
              if (isEditing) {
                context.read<WebAppsProvider>().saveCommonApps();
              }
              context.read<WebAppsProvider>().isEditingCommonApps = !isEditing;
            },
            borderRadius: BorderRadius.circular(15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: context.theme.canvasColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        R.ASSETS_ICONS_COMMON_APPS_EDIT_SVG,
                        width: 24.w,
                        height: 24.w,
                        color: context.textTheme.bodyText2.color,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.sp),
                  child: Text(
                    isEditing ? '完成' : '编辑',
                    style: TextStyle(fontSize: 18.sp),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Section widget for common apps.
  /// 常用应用的区域部件
  Widget commonAppsSection(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (BuildContext _, WebAppsProvider provider, Widget __) {
        final bool isEditing = provider.isEditingCommonApps;
        return AnimatedContainer(
          duration: kThemeChangeDuration,
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          height: (isEditing ? 120.0 : 176.0).h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.w),
            color: context.theme.colorScheme.surface,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (provider.commonWebApps.isEmpty)
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              '置顶应用会显示在这里',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        )
                      else ...<Widget>[
                        ...List<Widget>.generate(
                          provider.commonWebApps.length,
                          (int index) {
                            return Expanded(
                              child: appWidget(
                                context,
                                provider.commonWebApps.elementAt(index),
                                needIndicator: false,
                              ),
                            );
                          },
                        ),
                        ...List<Widget>.generate(
                          provider.maxCommonWebApps -
                              provider.commonWebApps.length,
                          (int _) => const Spacer(),
                        ),
                      ],
                      editingButton(context)
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: kThemeChangeDuration,
                height: isEditing ? 0 : 36.h,
                child: Center(
                  child: Text(
                    isEditing ? '' : '点击编辑对常用应用进行调整',
                    style: context.textTheme.caption.copyWith(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
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
      builder: (BuildContext _, WebAppsProvider provider, Widget __) {
        return InkWell(
          splashFactory: InkSplash.splashFactory,
          borderRadius: BorderRadius.circular(15.w),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(child: WebAppIcon(app: webApp, size: 72.0)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.sp),
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
    WebApp webApp,
    bool needIndicator,
  ) {
    final bool isCommon = provider.commonWebApps.contains(webApp);
    final bool isEditing = provider.isEditingCommonApps;
    final IconThemeData iconTheme = IconThemeData(
      color: context.iconTheme.color.withOpacity(0.5),
      size: 12.w,
    );
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
                  color: iconTheme.color,
                  width: iconTheme.size,
                  height: iconTheme.size,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// 分类列表组件
  Widget getSectionColumn(BuildContext context, String name) {
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
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
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
              body:
                  fetching ? const SpinKitWidget() : categoryListView(context),
            ),
          ),
        );
      },
    );
  }
}
