///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/3/19 15:09
///
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/controller/asset_entity_image_provider.dart';
import 'package:openjmu/widgets/image/photo_selector_viewer.dart';

@FFRoute(
  name: 'openjmu://photo-selector',
  routeName: '图片选择器',
  argumentNames: ['provider'],
)
class PhotoSelector extends StatelessWidget {
  const PhotoSelector({
    Key key,
    @required this.provider,
    int gridCount = 4,
  })  : assert(provider != null,
            'PhotoSelectorProvider must be provided and not null.'),
        gridCount = gridCount ?? 4,
        super(key: key);

  /// [ChangeNotifier] for photo selector.
  /// 图片选择器状态保持
  final PhotoSelectorProvider provider;

  /// Assets count for selector.
  /// 图片网格数
  final int gridCount;

  /// Static method to push with navigator.
  /// 跳转至选择器的静态方法
  static Future<Set<AssetEntity>> pushToPicker(
      PhotoSelectorProvider provider) async {
    final dynamic result = await navigatorState.pushNamed(
      Routes.OPENJMU_PHOTO_SELECTOR,
      arguments: <String, dynamic>{'provider': provider},
    );
    final Set<AssetEntity> set = result as Set<AssetEntity>;
    return set;
  }

  /// Space between asset item widget [_succeedItem].
  /// 资源部件之间的间隔
  double get itemSpacing => 2.0.w;

  /// [Curve] when triggering path switching.
  /// 切换路径时的动画曲线
  Curve get switchingPathCurve => Curves.easeInOut;

  /// [Duration] when triggering path switching.
  /// 切换路径时的动画时长
  Duration get switchingPathDuration => kThemeAnimationDuration * 1.5;

  /// [ThemeData] for selector.
  /// 选择器使用的主题
  ThemeData get theme =>
      Provider.of<ThemesProvider>(currentContext, listen: false).darkTheme;

  /// Path entity select widget.
  /// 路径选择部件
  Widget get pathEntitySelector => UnconstrainedBox(
        child: Consumer<PhotoSelectorProvider>(
          builder: (BuildContext _, PhotoSelectorProvider provider, Widget __) {
            return GestureDetector(
              onTap: () {
                provider.isSwitchingPath = !provider.isSwitchingPath;
              },
              child: Container(
                height: 38.0.h,
                constraints: BoxConstraints(maxWidth: Screens.width * 0.5),
                padding: EdgeInsets.only(left: 15.0.w, right: 8.0.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.w),
                  color: theme.dividerColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (provider.currentPathEntity != null)
                      Flexible(
                        child: Text(
                          '${provider.currentPathEntity.name}',
                          style: TextStyle(fontSize: 18.0.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(left: 6.0.w),
                      child: Transform.rotate(
                        angle: provider.isSwitchingPath ? math.pi : 0.0,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white54,
                          size: 24.0.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  /// Item widget for path entity selector.
  /// 路径单独条目选择组件
  Widget pathEntityWidget(AssetPathEntity pathEntity) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        onTap: () => provider.switchPath(pathEntity),
        child: SizedBox(
          height: 80.0.h,
          child: Row(
            children: <Widget>[
              RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Selector<PhotoSelectorProvider,
                      Map<AssetPathEntity, Uint8List>>(
                    selector:
                        (BuildContext _, PhotoSelectorProvider provider) =>
                            provider.pathEntityList,
                    builder: (BuildContext _,
                        Map<AssetPathEntity, Uint8List> pathEntityList,
                        Widget __) {
                      /// The reason that the `thumbData` should be checked at here to see if it is
                      /// null is that even the image file is not exist, the `File` can still
                      /// returned as it exist, which will cause the thumb bytes return null.
                      /// 此处需要检查缩略图为空的原因是：尽管文件可能已经被删除，但通过`File`读取的文件对象
                      /// 仍然存在，使得返回的数据为空。
                      final Uint8List thumbData = pathEntityList[pathEntity];
                      if (thumbData != null) {
                        return Image.memory(pathEntityList[pathEntity],
                            fit: BoxFit.cover);
                      } else {
                        return Container(color: Colors.white12);
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0.w),
                          child: Text(
                            '${pathEntity.name}',
                            style: TextStyle(fontSize: 20.0.sp, height: 1.25),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        '(${pathEntity.assetCount})',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 20.0.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Selector<PhotoSelectorProvider, AssetPathEntity>(
                selector: (BuildContext _, PhotoSelectorProvider provider) =>
                    provider.currentPathEntity,
                builder: (BuildContext _, AssetPathEntity currentPathEntity,
                    Widget __) {
                  if (currentPathEntity == pathEntity) {
                    return AspectRatio(
                      aspectRatio: 1.0,
                      child: Icon(Icons.check,
                          color: currentThemeColor, size: 32.0.w),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List widget for path entities.
  /// 路径选择列表组件
  Widget get pathEntityListWidget {
    final double maxHeight = Screens.height * 0.75;
    return Selector<PhotoSelectorProvider, bool>(
      selector: (BuildContext _, PhotoSelectorProvider provider) =>
          provider.isSwitchingPath,
      builder: (BuildContext _, bool isSwitchingPath, Widget __) {
        return AnimatedPositioned(
          duration: switchingPathDuration,
          curve: switchingPathCurve,
          top: -(!isSwitchingPath ? maxHeight : 1.0.h),
          child: Container(
            width: Screens.width,
            height: maxHeight,
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Selector<PhotoSelectorProvider,
                Map<AssetPathEntity, Uint8List>>(
              selector: (BuildContext _, PhotoSelectorProvider provider) =>
                  provider.pathEntityList,
              builder: (BuildContext _,
                  Map<AssetPathEntity, Uint8List> pathEntityList, Widget __) {
                return ListView.separated(
                  padding: EdgeInsets.only(top: 1.0.h),
                  itemCount: pathEntityList.length,
                  itemBuilder: (BuildContext _, int index) {
                    return pathEntityWidget(
                        pathEntityList.keys.elementAt(index));
                  },
                  separatorBuilder: (BuildContext _, int __) => Container(
                    height: 1.0.h,
                    color: const Color(0xff4e4e4e),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Confirm button.
  /// 确认按钮
  ///
  /// It'll pop with [PhotoSelectorProvider.selectedAssets] when there're any assets were chosen.
  /// 当有资源已选时，点击按钮将把已选资源通过路由返回。
  Widget get confirmButton => Consumer<PhotoSelectorProvider>(
        builder: (BuildContext _, PhotoSelectorProvider provider, Widget __) {
          return MaterialButton(
            minWidth: provider.isSelectedNotEmpty ? 50.0.w : 20.0.w,
            height: 38.0.h,
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            color: provider.isSelectedNotEmpty
                ? currentThemeColor
                : theme.dividerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0.w),
            ),
            child: Text(
              provider.isSelectedNotEmpty
                  ? '确认(${provider.selectedAssets.length}/${provider.maxAssets})'
                  : '确认',
              style: TextStyle(
                color: provider.isSelectedNotEmpty
                    ? Colors.white
                    : Colors.grey[600],
                fontSize: 18.0.sp,
                height: 1.25,
              ),
            ),
            onPressed: () {
              if (provider.isSelectedNotEmpty) {
                navigatorState.pop(provider.selectedAssets);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      );

  /// GIF image type indicator.
  /// GIF类型图片指示
  Widget get gifIndicator => Positioned(
        bottom: 6.0.w,
        right: 6.0.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.0.w, vertical: 2.0.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0.w),
            color: currentTheme.primaryColor.withOpacity(0.75),
          ),
          child: Text(
            '动图',
            style: TextStyle(
              color: currentTheme.iconTheme.color,
              fontSize: 14.0.sp,
            ),
          ),
        ),
      );

  /// Item widget when [AssetEntity.thumbData] loaded successfully.
  /// 资源缩略数据加载成功时使用的部件
  Widget _succeedItem(int index, Widget completedWidget,
      {SpecialAssetType specialAssetType}) {
    final AssetEntity item = provider.currentAssets.elementAt(index);
    return Selector<PhotoSelectorProvider, Set<AssetEntity>>(
      selector: (BuildContext _, PhotoSelectorProvider provider) =>
          provider.selectedAssets,
      builder: (BuildContext _, Set<AssetEntity> selectedAssets, Widget __) {
        final bool selected = provider.selectedAssets.contains(item);
        return Stack(
          children: <Widget>[
            Positioned.fill(child: RepaintBoundary(child: completedWidget)),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  PhotoSelectorViewer.pushToViewer(
                    currentIndex: index,
                    assets: provider.currentAssets,
                  );
                },
                child: AnimatedContainer(
                  duration: kThemeAnimationDuration,
                  color:
                      selected ? Colors.black45 : Colors.black.withOpacity(0.1),
                ),
              ), // 点击预览同目录下所有资源
            ),
            if (specialAssetType == SpecialAssetType.gif)
              gifIndicator,
            Positioned(
              top: 0.0,
              right: 0.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (selected) {
                    provider.unSelectAsset(item);
                  } else {
                    provider.selectAsset(item);
                  }
                },
                child: AnimatedContainer(
                  duration: kThemeAnimationDuration,
                  width: 25.0.w,
                  height: 25.0.w,
                  margin: EdgeInsets.all(8.0.w),
                  decoration: BoxDecoration(
                    border: !selected
                        ? Border.all(color: Colors.white, width: 2.0.w)
                        : null,
                    color: selected ? currentThemeColor : null,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: kThemeAnimationDuration,
                    reverseDuration: kThemeAnimationDuration,
                    child: selected
                        ? Text(
                            '${selectedAssets.toList().indexOf(item) + 1}',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18.0.sp),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ) // 角标,
          ],
        );
      },
    );
  }

  /// Item widget when [AssetEntity.thumbData] load failed.
  /// 资源缩略数据加载失败时使用的部件
  Widget get _failedItem => Center(
        child: Text(
          '加载失败',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18.0.sp),
        ),
      );

  /// [GridView] for assets under [PhotoSelectorProvider.currentPathEntity].
  /// 正在查看的目录下的资源网格部件
  Widget get assetsGrid => Selector<PhotoSelectorProvider, Set<AssetEntity>>(
        selector: (BuildContext _, PhotoSelectorProvider provider) =>
            provider.currentAssets,
        builder: (BuildContext _, Set<AssetEntity> currentAssets, Widget __) {
          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              mainAxisSpacing: itemSpacing,
              crossAxisSpacing: itemSpacing,
            ),
            itemCount: currentAssets.length,
            itemBuilder: (BuildContext _, int index) {
              final AssetEntityImageProvider imageProvider =
                  AssetEntityImageProvider(
                currentAssets.elementAt(index),
                isOriginal: false,
              );
              return RepaintBoundary(
                child: ExtendedImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  loadStateChanged: (ExtendedImageState state) {
                    Widget loader;
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        loader = SpinKitThreeBounce(
                          color: theme.iconTheme.color,
                          size: Screens.width / gridCount / 4,
                        ); // Loading widget. 加载控件
                        break;
                      case LoadState.completed:
                        SpecialAssetType type;
                        if (imageProvider.imageFileType == ImageFileType.gif) {
                          type = SpecialAssetType.gif;
                        }
                        loader = _succeedItem(index, state.completedWidget,
                            specialAssetType: type);
                        break;
                      case LoadState.failed:
                        loader = _failedItem;
                        break;
                    }
                    return loader;
                  },
                ),
              );
            },
          );
        },
      );

  /// Preview button to preview selected assets.
  /// 预览已选图片的按钮
  Widget get previewButton {
    return Selector<PhotoSelectorProvider, bool>(
      selector: (BuildContext _, PhotoSelectorProvider provider) =>
          provider.isSelectedNotEmpty,
      builder: (BuildContext _, bool isSelectedNotEmpty, Widget __) {
        return GestureDetector(
          onTap: isSelectedNotEmpty
              ? () async {
                  final Set<AssetEntity> result =
                      await PhotoSelectorViewer.pushToViewer(
                    currentIndex: 0,
                    assets: provider.selectedAssets,
                    selectedAssets: provider.selectedAssets,
                    selectorProvider: provider,
                  );
                  if (result != null) {
                    navigatorState.pop(result);
                  }
                }
              : null,
          child: Selector<PhotoSelectorProvider, Set<AssetEntity>>(
            selector: (BuildContext _, PhotoSelectorProvider provider) =>
                provider.selectedAssets,
            builder:
                (BuildContext _, Set<AssetEntity> selectedAssets, Widget __) {
              return Text(
                isSelectedNotEmpty
                    ? '预览(${provider.selectedAssets.length})'
                    : '预览',
                style: TextStyle(
                  color: isSelectedNotEmpty ? null : Colors.grey[600],
                  fontSize: 18.0.sp,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Action bar widget aligned to bottom.
  /// 底部操作栏部件
  Widget get bottomActionBar => Container(
        height: suSetHeight(kAppBarHeight / 1.4) + Screens.bottomSafeHeight,
        padding: EdgeInsets.only(
          left: 20.0.w,
          right: 20.0.w,
          bottom: Screens.bottomSafeHeight,
        ),
        color: theme.primaryColor,
        child: Row(children: <Widget>[previewButton]),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: theme,
        child: ChangeNotifierProvider<PhotoSelectorProvider>.value(
          value: provider,
          child: Material(
            color: theme.canvasColor,
            child: FixedAppBarWrapper(
              appBar: FixedAppBar(
                backgroundColor: theme.primaryColor,
                centerTitle: false,
                title: pathEntitySelector,
                actionsPadding: EdgeInsets.only(right: 20.0.w),
                actions: <Widget>[confirmButton],
              ),
              body: Selector<PhotoSelectorProvider, bool>(
                selector: (BuildContext _, PhotoSelectorProvider provider) =>
                    provider.hasAssetsToDisplay,
                builder: (BuildContext _, bool hasAssetsToDisplay, Widget __) {
                  return AnimatedSwitcher(
                    duration: kThemeAnimationDuration,
                    child: hasAssetsToDisplay
                        ? Stack(
                            children: <Widget>[
                              RepaintBoundary(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(child: assetsGrid),
                                    bottomActionBar,
                                  ],
                                ),
                              ),
                              pathEntityListWidget,
                            ],
                          )
                        : SpinKitThreeBounce(color: currentThemeColor),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
