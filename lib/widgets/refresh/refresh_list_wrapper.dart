///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/17/20 4:24 PM
///
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    hide CupertinoActivityIndicator;

import 'pull_to_refresh_header.dart';

double get maxDragOffset => 60.h;

class RefreshListWrapper extends StatelessWidget {
  const RefreshListWrapper({
    Key key,
    @required this.loadingBase,
    @required this.itemBuilder,
    this.dividerBuilder,
    this.controller,
    this.refreshHeaderTextStyle,
    this.indicatorPlaceholder,
    this.indicatorTextStyle,
    this.padding,
  }) : super(key: key);

  final LoadingBase loadingBase;
  final Widget Function(Map<String, dynamic> model) itemBuilder;
  final IndexedWidgetBuilder dividerBuilder;
  final ScrollController controller;
  final EdgeInsetsGeometry padding;

  final TextStyle refreshHeaderTextStyle;
  final Widget indicatorPlaceholder;
  final TextStyle indicatorTextStyle;

  static Widget indicatorBuilder(
    BuildContext context,
    IndicatorStatus status,
    LoadingBase loadingBase, {
    Widget indicatorPlaceholder,
    TextStyle indicatorTextStyle,
  }) {
    Widget indicator;
    switch (status) {
      case IndicatorStatus.none:
        indicator = const SizedBox.shrink();
        break;
      case IndicatorStatus.loadingMoreBusying:
        indicator = LoadMoreIndicator(
          canLoadMore: true,
          textStyle: indicatorTextStyle,
        );
        break;
      case IndicatorStatus.fullScreenBusying:
        indicator = LoadMoreIndicator(
          isSliver: true,
          canLoadMore: true,
          textStyle: indicatorTextStyle,
        );
        break;
      case IndicatorStatus.error:
        indicator = ListEmptyIndicator(
          isSliver: false,
          isError: true,
          loadingBase: loadingBase,
          indicator: indicatorPlaceholder,
          textStyle: indicatorTextStyle,
        );
        break;
      case IndicatorStatus.fullScreenError:
        indicator = ListEmptyIndicator(
          isError: true,
          loadingBase: loadingBase,
          indicator: indicatorPlaceholder,
          textStyle: indicatorTextStyle,
        );
        break;
      case IndicatorStatus.noMoreLoad:
        indicator = LoadMoreIndicator(
          canLoadMore: false,
          textStyle: indicatorTextStyle,
        );
        break;
      case IndicatorStatus.empty:
        indicator = ListEmptyIndicator(
          loadingBase: loadingBase,
          indicator: indicatorPlaceholder,
          textStyle: indicatorTextStyle,
        );
        break;
    }
    return indicator;
  }

  @override
  Widget build(BuildContext context) {
    SliverListConfig<Map<String, dynamic>> config;
    if (dividerBuilder != null) {
      config = SliverListConfig<Map<String, dynamic>>(
        sourceList: loadingBase,
        padding: padding ?? EdgeInsets.symmetric(vertical: 10.w),
        lastChildLayoutType: LastChildLayoutType.fullCrossAxisExtent,
        childCountBuilder: (int length) => length == 0 ? 0 : length * 2 - 1,
        itemBuilder: (BuildContext c, Map<String, dynamic> model, int index) {
          if (index.isEven) {
            return itemBuilder(loadingBase[index ~/ 2]);
          }
          return dividerBuilder(c, index);
        },
        indicatorBuilder: (BuildContext context, IndicatorStatus status) {
          return indicatorBuilder(
            context,
            status,
            loadingBase,
            indicatorPlaceholder: indicatorPlaceholder,
            indicatorTextStyle: indicatorTextStyle,
          );
        },
      );
    } else {
      config = SliverListConfig<Map<String, dynamic>>(
        sourceList: loadingBase,
        padding: padding ?? EdgeInsets.symmetric(vertical: 10.w),
        lastChildLayoutType: LastChildLayoutType.fullCrossAxisExtent,
        itemBuilder: (BuildContext _, Map<String, dynamic> model, int index) {
          return itemBuilder(model);
        },
        indicatorBuilder: (BuildContext context, IndicatorStatus status) {
          return indicatorBuilder(
            context,
            status,
            loadingBase,
            indicatorPlaceholder: indicatorPlaceholder,
            indicatorTextStyle: indicatorTextStyle,
          );
        },
      );
    }
    return PullToRefreshNotification(
      onRefresh: loadingBase.refresh,
      maxDragOffset: maxDragOffset,
      pullBackCurve: Curves.easeInQuint,
      pullBackDuration: 1.seconds,
      child: LoadingMoreCustomScrollView(
        rebuildCustomScrollView: true,
        controller: controller,
        slivers: <Widget>[
          PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
            return PullToRefreshHeader.buildRefreshHeader(
              context,
              info,
              textStyle: refreshHeaderTextStyle,
            );
          }),
          LoadingMoreSliverList<Map<String, dynamic>>(config),
        ],
      ),
    );
  }
}

class ListMoreIndicator extends StatelessWidget {
  const ListMoreIndicator({
    Key key,
    this.isSliver = true,
    this.isRequesting = false,
    this.textStyle,
  }) : super(key: key);

  final bool isSliver;
  final bool isRequesting;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = SizedBox(
      height: 60.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedSwitcher(
            duration: kTabScrollDuration,
            child: isRequesting
                ? const LoadMoreSpinningIcon(isRefreshing: true, size: 32)
                : const SizedBox.shrink(),
          ),
          AnimatedContainer(
            duration: kTabScrollDuration,
            width: isRequesting ? 12.w : 0,
          ),
          Text(isRequesting ? '加载中...' : '暂无更多'),
        ],
      ),
    );
    if (isSliver) {
      child = SliverFillRemaining(child: Center(child: child));
    }
    return DefaultTextStyle.merge(
      style: textStyle ?? TextStyle(fontSize: 18.sp, height: 1.24),
      child: child,
    );
  }
}

class ListEmptyIndicator extends StatelessWidget {
  const ListEmptyIndicator({
    Key key,
    this.isSliver = true,
    this.isError = false,
    this.loadingBase,
    this.indicator,
    this.textStyle,
  })  : assert(loadingBase != null || !isError),
        super(key: key);

  final bool isSliver;
  final bool isError;
  final LoadingBase loadingBase;
  final Widget indicator;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = GestureDetector(
      onTap: isError ? loadingBase.refresh : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (indicator != null)
            indicator
          else ...<Widget>[
            SvgPicture.asset(
              R.ASSETS_PLACEHOLDERS_NO_NETWORK_SVG,
              width: 50.w,
              color: context.theme.iconTheme.color,
            ),
            VGap(20.w),
            Text(
              isError ? '出错了~点此重试' : '空空如也',
              style: textStyle ??
                  TextStyle(
                    color: context.textTheme.caption.color,
                    fontSize: 22.sp,
                  ),
            ),
          ],
          VGap(Screens.height / 6),
        ],
      ),
    );
    if (isSliver) {
      child = SliverFillRemaining(child: child);
    }
    return DefaultTextStyle(
      style: textStyle ??
          context.textTheme.caption.copyWith(
            fontSize: 17.sp,
            height: 1.4,
          ),
      textAlign: TextAlign.center,
      child: child,
    );
  }
}
