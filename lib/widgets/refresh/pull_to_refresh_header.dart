///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/9/15 12:28
///
import 'package:flutter/cupertino.dart' hide RefreshIndicatorMode;
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class PullToRefreshHeader extends StatelessWidget {
  const PullToRefreshHeader({
    Key key,
    this.info,
    this.textStyle,
  }) : super(key: key);

  final PullToRefreshScrollNotificationInfo info;
  final TextStyle textStyle;

  static Widget buildRefreshHeader(
    BuildContext context,
    PullToRefreshScrollNotificationInfo info, {
    TextStyle textStyle,
  }) {
    final double offset = info?.dragOffset ?? 0.0;
    final RefreshIndicatorMode mode = info?.mode;

    Widget child;
    if (mode == RefreshIndicatorMode.error) {
      child = GestureDetector(
        onTap: info?.pullToRefreshNotificationState?.show,
        child: SizedBox(
          height: offset,
          child: const Center(child: Text('点击重试')),
        ),
      );
    } else {
      child = PullToRefreshHeader(info: info);
    }

    return SliverToBoxAdapter(
      child: DefaultTextStyle(
        style: textStyle ??
            context.textTheme.caption.copyWith(
              fontSize: 18.sp,
              height: 1.4,
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (info == null) {
      return const SizedBox.shrink();
    }

    bool isRefreshingMode = false;
    String text;
    switch (info.mode) {
      case RefreshIndicatorMode.snap:
      case RefreshIndicatorMode.refresh:
        isRefreshingMode = true;
        text = '正在刷新';
        break;
      case RefreshIndicatorMode.canceled:
      case RefreshIndicatorMode.drag:
        text = '下拉刷新';
        break;
      case RefreshIndicatorMode.armed:
        text = '松手刷新';
        break;
      case RefreshIndicatorMode.done:
        text = '刷新成功';
        break;
      case RefreshIndicatorMode.error:
        text = '刷新失败';
        break;
      default:
        text = '下拉刷新';
        break;
    }

    final double dragOffset = info?.dragOffset ?? 0.0;

    return Container(
      height: dragOffset,
      padding: EdgeInsets.only(top: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedSwitcher(
            duration: kTabScrollDuration,
            child: LoadMoreSpinningIcon(isRefreshing: isRefreshingMode),
          ),
          Gap(10.w),
          Text(text),
        ],
      ),
    );
  }
}
