///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-03-11 09:53
///
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://publish-post", routeName: "发布动态")
class PublishPostPage extends StatefulWidget {
  @override
  _PublishPostPageState createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final LoadingDialogController _dialogController = LoadingDialogController();
  final FocusNode _focusNode = FocusNode();

  bool isLoading = false;
  bool textFieldEnable = true;
  bool emoticonPadActive = false;

  int imagesLength = 0, maxImagesLength = 9, uploadedImages = 1;

  int currentLength = 0;
  int currentOffset;
  double _keyboardHeight = EmotionPad.emoticonPadDefaultHeight;

  Future<void> pickAssets() async {
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      context: context,
      themeColor: currentThemeColor,
      padding: 1.0,
      dividerColor: Colors.grey,
      disableColor: Colors.grey.shade300,
      maxSelected: 9,
      provider: I18nProvider.chinese,
      rowCount: 4,
      thumbSize: 150,
      textColor: Colors.white,
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.blue,
      ),
      pickType: PickType.onlyImage,
    );
  }

  Widget get publishButton => MaterialButton(
        color: currentThemeColor,
        minWidth: suSetWidth(120.0),
        height: suSetHeight(50.0),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(13.0)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: suSetWidth(6.0)),
              child: Icon(
                Icons.create,
                color: Colors.white,
                size: suSetWidth(28.0),
              ),
            ),
            Text(
              '发动态',
              style: TextStyle(
                color: Colors.white,
                fontSize: suSetSp(20.0),
                height: 1.24,
              ),
            ),
          ],
        ),
        onPressed: () {},
      );

  Widget get textField => Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(20.0),
            vertical: suSetHeight(10.0),
          ),
          child: ExtendedTextField(
            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
            controller: _textEditingController,
            focusNode: _focusNode,
            autofocus: true,
            cursorColor: Theme.of(context).cursorColor,
            enabled: !isLoading,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterStyle: TextStyle(color: Colors.transparent),
              hintText: '分享你的动态...',
              hintStyle: TextStyle(
                color: Colors.grey,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            buildCounter: emptyCounterBuilder,
            style: currentTheme.textTheme.body1.copyWith(
              fontSize: suSetSp(22.0),
              textBaseline: TextBaseline.alphabetic,
            ),
            maxLines: null,
            onChanged: (content) {
              currentLength = content.length;
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        actions: <Widget>[publishButton],
      ),
      body: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            textField,
            FlatButton(
              onPressed: () {
                pickAssets();
              },
              child: Text('Pick assets.'),
            ),
          ],
        ),
      ),
    );
  }
}
