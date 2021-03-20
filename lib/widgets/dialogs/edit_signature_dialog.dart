///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/17/21 8:22 PM
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://edit-signature-dialog',
  routeName: '编辑个性签名',
  pageRouteType: PageRouteType.transparent,
)
class EditSignatureDialog extends StatefulWidget {
  const EditSignatureDialog({Key key}) : super(key: key);

  @override
  _EditSignatureDialogState createState() => _EditSignatureDialogState();
}

class _EditSignatureDialogState extends State<EditSignatureDialog> {
  final ValueNotifier<bool> _requesting = ValueNotifier<bool>(false);

  TextEditingController _tec;

  @override
  void initState() {
    super.initState();
    _tec = TextEditingController(text: UserAPI.currentUser.signature);
  }

  @override
  void dispose() {
    _requesting.dispose();
    _tec.dispose();
    super.dispose();
  }

  Future<void> _request(BuildContext context) async {
    if (_requesting.value) {
      return;
    }
    _requesting.value = true;
    try {
      await UserAPI.setSignature(_tec.text);
      UserAPI.currentUser = UserAPI.currentUser.copyWith(signature: _tec.text);
      showToast('个性签名已更新');
      context.navigator.pop(true);
    } catch (e) {
      LogUtils.e('Error when update signature: $e');
      showErrorToast('修改失败');
      _requesting.value = false;
    }
  }

  Widget textField(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      height: 56.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _requesting,
        builder: (_, bool value, __) => ExtendedTextField(
          autofocus: true,
          controller: _tec,
          cursorColor: currentThemeColor,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 14.sp,
            ),
            isDense: true,
            border: InputBorder.none,
            hintText: ' 输入您的个性签名',
            suffix: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _tec,
              builder: (_, TextEditingValue value, __) => Text(
                '${value.text.length}/$maxLength',
                style: TextStyle(
                  color:
                      value.text.length > maxLength ? context.themeColor : null,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          maxLength: maxLength,
          buildCounter: emptyCounterBuilder,
          enabled: !value,
          style: context.textTheme.bodyText2.copyWith(
            height: 1.2,
            fontSize: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _publishButton(BuildContext context) {
    return ValueListenableBuilder2<TextEditingValue, bool>(
      firstNotifier: _tec,
      secondNotifier: _requesting,
      builder: (_, TextEditingValue tv, bool isRequesting, __) {
        final bool canSend =
            tv.text.isNotEmpty && tv.text != UserAPI.currentUser.signature;
        return Tapper(
          onTap: canSend ? () => _request(context) : null,
          child: Container(
            width: 84.w,
            height: 56.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: currentThemeColor.withOpacity(canSend ? 1 : 0.3),
            ),
            alignment: Alignment.center,
            child: isRequesting
                ? Container(
                    padding: EdgeInsets.all(15.w),
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PlatformProgressIndicator(
                        color: adaptiveButtonColor(),
                      ),
                    ),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      color: adaptiveButtonColor(),
                      height: 1.2,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Tapper(
              onTap: context.navigator.pop,
              child: Container(color: Colors.black26),
            ),
          ),
          ColoredBox(
            color: context.theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: textField(context)),
                      Gap(16.w),
                      _publishButton(context),
                    ],
                  ),
                ),
                SizedBox(
                  height: math.max(context.bottomInsets, context.bottomPadding),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
