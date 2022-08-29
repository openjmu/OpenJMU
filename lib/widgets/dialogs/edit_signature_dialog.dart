///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/17/21 8:22 PM
///
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class EditSignatureDialog extends StatefulWidget {
  const EditSignatureDialog({Key? key}) : super(key: key);

  static Future<bool?> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => const EditSignatureDialog(),
      useSafeArea: false,
    );
  }

  @override
  _EditSignatureDialogState createState() => _EditSignatureDialogState();
}

class _EditSignatureDialogState extends State<EditSignatureDialog> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isEmoticonPadActive = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _requesting = ValueNotifier<bool>(false);
  final TextEditingController _tec = TextEditingController(
    text: UserAPI.currentUser.signature,
  );

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
      LogUtil.e('Error when update signature: $e');
      showErrorToast('修改失败');
      _requesting.value = false;
    }
  }

  void updateEmoticonPadStatus(bool active) {
    if (context.bottomInsets > 0) {
      InputUtils.hideKeyboard();
    }
    _isEmoticonPadActive.value = active;
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
          ),
          enabled: !value,
          style: context.textTheme.bodyText2?.copyWith(
            height: 1.2,
            fontSize: 20.sp,
          ),
          specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
        ),
      ),
    );
  }

  Widget _emojiButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEmoticonPadActive,
      builder: (_, bool value, __) => Tapper(
        onTap: () {
          if (value && _focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
          updateEmoticonPadStatus(!value);
        },
        child: Container(
          alignment: Alignment.center,
          width: 60.w,
          height: 60.w,
          margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 15.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color: context.theme.canvasColor,
          ),
          child: SvgPicture.asset(
            value
                ? R.ASSETS_ICONS_PUBLISH_EMOJI_ACTIVE_SVG
                : R.ASSETS_ICONS_PUBLISH_EMOJI_SVG,
            width: 20.w,
            height: 20.w,
            color: context.textTheme.bodyText2?.color,
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
    return EmojiKeyboardWrapper(
      controller: _tec,
      emoticonPadNotifier: _isEmoticonPadActive,
      child: Container(
        color: context.theme.colorScheme.surface,
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: <Widget>[
            Expanded(child: textField(context)),
            Gap.h(16.w),
            _emojiButton(context),
            _publishButton(context),
          ],
        ),
      ),
    );
  }
}
