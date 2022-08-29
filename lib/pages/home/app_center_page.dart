///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-07 19:39
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://app-center-page', routeName: '应用中心')
class AppCenterPage extends StatelessWidget {
  const AppCenterPage({Key? key}) : super(key: key);

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
            itemBuilder: (_, int index) => _list[index],
          ),
        ),
      ],
    );
  }

  Widget editingButton(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (_, WebAppsProvider provider, __) {
        final bool isEditing = provider.isEditingCommonApps;
        return Tapper(
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
                color: context.textTheme.bodyText2?.color,
              ),
              Gap.h(10.w),
              Text(isEditing ? '完成' : '编辑'),
            ],
          ),
        );
      },
    );
  }

  Widget _commonAppWidget(BuildContext context, WebApp app) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Selector<WebAppsProvider, bool>(
          selector: (_, WebAppsProvider p) => p.isEditingCommonApps,
          builder: (_, bool isEditingCommonApps, __) => Stack(
            children: <Widget>[
              Positioned.fill(child: WebAppIcon(app: app)),
              if (isEditingCommonApps)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Tapper(
                    onTap: () {
                      context.read<WebAppsProvider>().removeCommonApp(app);
                    },
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: const BoxDecoration(
                        color: defaultLightColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: 45 * (math.pi / 180),
                          child: SvgPicture.asset(
                            R.ASSETS_ICONS_APP_CENTER_ADD_SVG,
                            color: Colors.white,
                            width: 10.w,
                            height: 10.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section widget for common apps.
  /// 常用应用的区域部件
  Widget commonAppsSection(BuildContext context) {
    return Consumer<WebAppsProvider>(
      builder: (_, WebAppsProvider provider, __) {
        final bool isEditing = provider.isEditingCommonApps;
        return DefaultTextStyle.merge(
          style: TextStyle(height: 1.2, fontSize: 20.sp),
          child: Container(
            height: 80.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              border: Border(bottom: dividerBS(context)),
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
                              style: TextStyle(
                                color: context.textTheme.caption?.color,
                              ),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List<Widget>.generate(
                            provider.commonWebApps.length,
                            (int index) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.w),
                              child: _commonAppWidget(
                                _,
                                provider.commonWebApps.elementAt(index),
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
      builder: (_, WebAppsProvider provider, Widget? child) {
        return Tapper(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              child!,
              if (provider.isEditingCommonApps)
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
              API.launchWeb(url: webApp.replacedUrl!, app: webApp);
            }
          },
          onLongPress: !provider.isEditingCommonApps
              ? () async {
                  final bool confirm = await ConfirmationDialog.show(
                    context,
                    title: '跳转提醒',
                    content: '长按应用图标将在外部浏览器中打开应用，请确认跳转',
                    showConfirm: true,
                  );
                  if (confirm) {
                    API.launchOnDevice(webApp.replacedUrl!);
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
                '${webApp.name ?? webApp.appId}',
                style: context.textTheme.bodyText2?.copyWith(
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
    return PositionedDirectional(
      top: 15.w,
      end: 20.w,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: isCommon ? defaultLightColor : const Color(0xff1c7ece),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.rotate(
            angle: isCommon ? 45 * (math.pi / 180) : 0,
            child: SvgPicture.asset(
              R.ASSETS_ICONS_APP_CENTER_ADD_SVG,
              color: Colors.white,
              width: 12.w,
              height: 12.w,
            ),
          ),
        ),
      ),
    );
  }

  /// 分类列表组件
  Widget getSectionColumn(BuildContext context, String name) {
    return Selector<WebAppsProvider, Map<String, Set<WebApp>>>(
      selector: (_, WebAppsProvider p) => p.appCategoriesList,
      builder: (_, Map<String, Set<WebApp>> appCategoriesList, __) {
        final Set<WebApp>? list = appCategoriesList[name];
        if (list == null || list.isEmpty) {
          return const SizedBox.shrink();
        }
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
                    WebApp.category[name]!,
                    style: context.textTheme.bodyText2?.copyWith(
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
                itemBuilder: (_, int index) => appWidget(
                  context,
                  list.elementAt(index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool fetching = context.select<WebAppsProvider, bool>(
      (WebAppsProvider provider) => provider.fetching,
    );
    return Selector<WebAppsProvider, bool>(
      selector: (_, WebAppsProvider provider) => provider.isEditingCommonApps,
      builder: (_, bool isEditingCommonApps, Widget? child) => WillPopScope(
        onWillPop: () {
          if (isEditingCommonApps) {
            context.read<WebAppsProvider>().saveCommonApps();
            context.read<WebAppsProvider>().isEditingCommonApps =
                !isEditingCommonApps;
          }
          return Future<bool>.value(!isEditingCommonApps);
        },
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: Color.lerp(
          context.theme.canvasColor,
          context.theme.colorScheme.surface,
          0.5,
        ),
        body: FixedAppBarWrapper(
          appBar: const FixedAppBar(title: Text('应用中心')),
          body: fetching
              ? const Center(child: LoadMoreSpinningIcon(isRefreshing: true))
              : categoryListView(context),
        ),
      ),
    );
  }
}
