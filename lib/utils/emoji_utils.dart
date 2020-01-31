import 'dart:math';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class EmoticonUtils {
  static final String _emoticonFilePath = 'assets/emotionIcons';
  static final Map<String, String> emoticonMap = {
    '[微笑2]': '$_emoticonFilePath/微笑2.png',
    '[撇嘴1]': '$_emoticonFilePath/撇嘴1.png',
    '[色4]': '$_emoticonFilePath/色4.png',
    '[发呆2]': '$_emoticonFilePath/发呆2.png',
    '[得意1]': '$_emoticonFilePath/得意1.png',
    '[流泪2]': '$_emoticonFilePath/流泪2.png',
    '[害羞5]': '$_emoticonFilePath/害羞5.png',
    '[闭嘴1]': '$_emoticonFilePath/闭嘴1.png',
    '[睡]': '$_emoticonFilePath/睡.png',
    '[大哭7]': '$_emoticonFilePath/大哭7.png',
    '[尴尬1]': '$_emoticonFilePath/尴尬1.png',
    '[发怒]': '$_emoticonFilePath/发怒.png',
    '[调皮1]': '$_emoticonFilePath/调皮1.png',
    '[呲牙]': '$_emoticonFilePath/呲牙.png',
    '[惊讶4]': '$_emoticonFilePath/惊讶4.png',
    '[难过]': '$_emoticonFilePath/难过.png',
    '[酷]': '$_emoticonFilePath/酷.png',
    '[冷汗]': '$_emoticonFilePath/冷汗.png',
    '[抓狂]': '$_emoticonFilePath/抓狂.png',
    '[吐]': '$_emoticonFilePath/吐.png',
    '[偷笑2]': '$_emoticonFilePath/偷笑2.png',
    '[可爱1]': '$_emoticonFilePath/可爱1.png',
    '[白眼1]': '$_emoticonFilePath/白眼1.png',
    '[傲慢]': '$_emoticonFilePath/傲慢.png',
    '[饥饿2]': '$_emoticonFilePath/饥饿2.png',
    '[困]': '$_emoticonFilePath/困.png',
    '[惊恐1]': '$_emoticonFilePath/惊恐1.png',
    '[流汗2]': '$_emoticonFilePath/流汗2.png',
    '[憨笑]': '$_emoticonFilePath/憨笑.png',
    '[大兵]': '$_emoticonFilePath/大兵.png',

    // 奋斗1
    '[咒骂]': '$_emoticonFilePath/咒骂.png',
    '[疑问2]': '$_emoticonFilePath/疑问2.png',
    '[嘘]': '$_emoticonFilePath/嘘.png',
    '[晕3]': '$_emoticonFilePath/晕3.png',
    '[折磨1]': '$_emoticonFilePath/折磨1.png',
    '[衰1]': '$_emoticonFilePath/衰1.png',
    '[骷髅]': '$_emoticonFilePath/骷髅.png',
    // 敲打
    '[再见]': '$_emoticonFilePath/再见.png',

    // 擦汗
    // 抠鼻
    '[鼓掌1]': '$_emoticonFilePath/鼓掌1.png',
    '[糗大了]': '$_emoticonFilePath/糗大了.png',
    '[坏笑1]': '$_emoticonFilePath/坏笑1.png',

    // 左哼哼
    // 右哼哼
    '[哈欠]': '$_emoticonFilePath/哈欠.png',
    '[鄙视2]': '$_emoticonFilePath/鄙视2.png',
    '[委屈1]': '$_emoticonFilePath/委屈1.png',
    '[快哭了]': '$_emoticonFilePath/快哭了.png',
    '[阴险]': '$_emoticonFilePath/阴险.png',
    '[亲亲]': '$_emoticonFilePath/亲亲.png',
    '[吓]': '$_emoticonFilePath/吓.png',
    '[可怜2]': '$_emoticonFilePath/可怜2.png',

    // 菜刀
    '[西瓜]': '$_emoticonFilePath/西瓜.png',
    '[啤酒]': '$_emoticonFilePath/啤酒.png',
    '[篮球]': '$_emoticonFilePath/篮球.png',
    '[乒乓]': '$_emoticonFilePath/乒乓.png',
    '[咖啡]': '$_emoticonFilePath/咖啡.png',
    '[饭]': '$_emoticonFilePath/饭.png',
    '[猪头]': '$_emoticonFilePath/猪头.png',
    '[玫瑰]': '$_emoticonFilePath/玫瑰.png',
    '[凋谢]': '$_emoticonFilePath/凋谢.png',
    '[示爱]': '$_emoticonFilePath/示爱.png',
    '[爱心]': '$_emoticonFilePath/爱心.png',
    '[心碎]': '$_emoticonFilePath/心碎.png',
    '[蛋糕]': '$_emoticonFilePath/蛋糕.png',
    '[闪电]': '$_emoticonFilePath/闪电.png',
    '[炸弹]': '$_emoticonFilePath/炸弹.png',
    '[刀]': '$_emoticonFilePath/刀.png',
    '[足球]': '$_emoticonFilePath/足球.png',
    '[瓢虫]': '$_emoticonFilePath/瓢虫.png',
    '[便便]': '$_emoticonFilePath/便便.png',
    '[月亮]': '$_emoticonFilePath/月亮.png',
    '[太阳]': '$_emoticonFilePath/太阳.png',
    '[礼物]': '$_emoticonFilePath/礼物.png',
    '[拥抱]': '$_emoticonFilePath/拥抱.png',
    '[强]': '$_emoticonFilePath/强.png',
    '[弱]': '$_emoticonFilePath/弱.png',
    '[握手]': '$_emoticonFilePath/握手.png',
    '[胜利]': '$_emoticonFilePath/胜利.png',
    '[抱拳]': '$_emoticonFilePath/抱拳.png',

    // 勾引
    '[拳头]': '$_emoticonFilePath/拳头.png',

    // 差劲
    '[爱你]': '$_emoticonFilePath/爱你.png',
    '[NO]': '$_emoticonFilePath/NO.png',
    '[OK]': '$_emoticonFilePath/OK.png',
    '[爱情]': '$_emoticonFilePath/爱情.png',
    // 飞吻1
    // 跳跳
    // 发抖
    // 怄火
    // 转圈
    // 磕头
    // 回头
    // 跳绳
    // 挥手
    // 激动3
    // 街舞
    // 献舞
    // 左太极
    // 右太极
  };
}

class EmotionPad extends StatefulWidget {
  final String route;
  final double height;
  final TextEditingController controller;

  EmotionPad({
    Key key,
    this.route,
    this.height,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EmotionPadState();
}

class EmotionPadState extends State<EmotionPad> {
  static double get emoticonPadDefaultHeight => suSetHeight(260.0);
  static double emoticonPadHeight;

  void insertText(String text) {
    final value = widget.controller.value;
    final start = value.selection.baseOffset;
    final end = value.selection.extentOffset;

    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
      }
      widget.controller.value = value.copyWith(
        text: newText,
        selection: value.selection.copyWith(
          baseOffset: end + text.length,
          extentOffset: end + text.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = max(emoticonPadDefaultHeight, widget.height);
    return Container(
      color: Theme.of(context).canvasColor,
      height: height,
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(suSetWidth(6.0)),
          child: IconButton(
            icon: Image.asset(
              EmoticonUtils.emoticonMap.values.elementAt(index),
              fit: BoxFit.contain,
            ),
            onPressed: () {
              insertText(EmoticonUtils.emoticonMap.keys.elementAt(index));
            },
          ),
        ),
        itemCount: EmoticonUtils.emoticonMap.values.length,
      ),
    );
  }
}
