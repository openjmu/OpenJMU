import 'dart:math';
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';

class EmojiUtils {
  final Map<String, String> _emojiMap = Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/emotionIcons";

  static EmojiUtils _instance;
  static EmojiUtils get instance {
    if (_instance == null) _instance = EmojiUtils._();
    return _instance;
  }

  EmojiUtils._() {
    _emojiMap["[微笑2]"] = "$_emojiFilePath/微笑2.png";
    _emojiMap["[撇嘴1]"] = "$_emojiFilePath/撇嘴1.png";
    _emojiMap["[色4]"] = "$_emojiFilePath/色4.png";
    _emojiMap["[发呆2]"] = "$_emojiFilePath/发呆2.png";
    _emojiMap["[得意1]"] = "$_emojiFilePath/得意1.png";
    _emojiMap["[流泪2]"] = "$_emojiFilePath/流泪2.png";
    _emojiMap["[害羞5]"] = "$_emojiFilePath/害羞5.png";
    _emojiMap["[闭嘴1]"] = "$_emojiFilePath/闭嘴1.png";
    _emojiMap["[睡]"] = "$_emojiFilePath/睡.png";
    _emojiMap["[大哭7]"] = "$_emojiFilePath/大哭7.png";
    _emojiMap["[尴尬1]"] = "$_emojiFilePath/尴尬1.png";
    _emojiMap["[发怒]"] = "$_emojiFilePath/发怒.png";
    _emojiMap["[调皮1]"] = "$_emojiFilePath/调皮1.png";
    _emojiMap["[呲牙]"] = "$_emojiFilePath/呲牙.png";
    _emojiMap["[惊讶4]"] = "$_emojiFilePath/惊讶4.png";
    _emojiMap["[难过]"] = "$_emojiFilePath/难过.png";
    _emojiMap["[酷]"] = "$_emojiFilePath/酷.png";
    _emojiMap["[冷汗]"] = "$_emojiFilePath/冷汗.png";
    _emojiMap["[抓狂]"] = "$_emojiFilePath/抓狂.png";
    _emojiMap["[吐]"] = "$_emojiFilePath/吐.png";
    _emojiMap["[偷笑2]"] = "$_emojiFilePath/偷笑2.png";
    _emojiMap["[可爱1]"] = "$_emojiFilePath/可爱1.png";
    _emojiMap["[白眼1]"] = "$_emojiFilePath/白眼1.png";
    _emojiMap["[傲慢]"] = "$_emojiFilePath/傲慢.png";
    _emojiMap["[饥饿2]"] = "$_emojiFilePath/饥饿2.png";
    _emojiMap["[困]"] = "$_emojiFilePath/困.png";
    _emojiMap["[惊恐1]"] = "$_emojiFilePath/惊恐1.png";
    _emojiMap["[流汗2]"] = "$_emojiFilePath/流汗2.png";
    _emojiMap["[憨笑]"] = "$_emojiFilePath/憨笑.png";
    _emojiMap["[大兵]"] = "$_emojiFilePath/大兵.png";
    /// 奋斗1
    _emojiMap["[咒骂]"] = "$_emojiFilePath/咒骂.png";
    _emojiMap["[疑问2]"] = "$_emojiFilePath/疑问2.png";
    _emojiMap["[嘘]"] = "$_emojiFilePath/嘘.png";
    _emojiMap["[晕3]"] = "$_emojiFilePath/晕3.png";
    _emojiMap["[折磨1]"] = "$_emojiFilePath/折磨1.png";
    _emojiMap["[衰1]"] = "$_emojiFilePath/衰1.png";
    _emojiMap["[骷髅]"] = "$_emojiFilePath/骷髅.png";
    /// 敲打
    _emojiMap["[再见]"] = "$_emojiFilePath/再见.png";
    /// 擦汗
    /// 抠鼻
    _emojiMap["[鼓掌1]"] = "$_emojiFilePath/鼓掌1.png";
    _emojiMap["[糗大了]"] = "$_emojiFilePath/糗大了.png";
    _emojiMap["[坏笑1]"] = "$_emojiFilePath/坏笑1.png";
    /// 左哼哼
    /// 右哼哼
    _emojiMap["[哈欠]"] = "$_emojiFilePath/哈欠.png";
    _emojiMap["[鄙视2]"] = "$_emojiFilePath/鄙视2.png";
    _emojiMap["[委屈1]"] = "$_emojiFilePath/委屈1.png";
    _emojiMap["[快哭了]"] = "$_emojiFilePath/快哭了.png";
    _emojiMap["[阴险]"] = "$_emojiFilePath/阴险.png";
    _emojiMap["[亲亲]"] = "$_emojiFilePath/亲亲.png";
    _emojiMap["[吓]"] = "$_emojiFilePath/吓.png";
    _emojiMap["[可怜2]"] = "$_emojiFilePath/可怜2.png";
    /// 菜刀
    _emojiMap["[西瓜]"] = "$_emojiFilePath/西瓜.png";
    _emojiMap["[啤酒]"] = "$_emojiFilePath/啤酒.png";
    _emojiMap["[篮球]"] = "$_emojiFilePath/篮球.png";
    _emojiMap["[乒乓]"] = "$_emojiFilePath/乒乓.png";
    _emojiMap["[咖啡]"] = "$_emojiFilePath/咖啡.png";
    _emojiMap["[饭]"] = "$_emojiFilePath/饭.png";
    _emojiMap["[猪头]"] = "$_emojiFilePath/猪头.png";
    _emojiMap["[玫瑰]"] = "$_emojiFilePath/玫瑰.png";
    _emojiMap["[凋谢]"] = "$_emojiFilePath/凋谢.png";
    _emojiMap["[示爱]"] = "$_emojiFilePath/示爱.png";
    _emojiMap["[爱心]"] = "$_emojiFilePath/爱心.png";
    _emojiMap["[心碎]"] = "$_emojiFilePath/心碎.png";
    _emojiMap["[蛋糕]"] = "$_emojiFilePath/蛋糕.png";
    _emojiMap["[闪电]"] = "$_emojiFilePath/闪电.png";
    _emojiMap["[炸弹]"] = "$_emojiFilePath/炸弹.png";
    _emojiMap["[刀]"] = "$_emojiFilePath/刀.png";
    _emojiMap["[足球]"] = "$_emojiFilePath/足球.png";
    _emojiMap["[瓢虫]"] = "$_emojiFilePath/瓢虫.png";
    _emojiMap["[便便]"] = "$_emojiFilePath/便便.png";
    _emojiMap["[月亮]"] = "$_emojiFilePath/月亮.png";
    _emojiMap["[太阳]"] = "$_emojiFilePath/太阳.png";
    _emojiMap["[礼物]"] = "$_emojiFilePath/礼物.png";
    _emojiMap["[拥抱]"] = "$_emojiFilePath/拥抱.png";
    _emojiMap["[强]"] = "$_emojiFilePath/强.png";
    _emojiMap["[弱]"] = "$_emojiFilePath/弱.png";
    _emojiMap["[握手]"] = "$_emojiFilePath/握手.png";
    _emojiMap["[胜利]"] = "$_emojiFilePath/胜利.png";
    _emojiMap["[抱拳]"] = "$_emojiFilePath/抱拳.png";
    /// 勾引
    _emojiMap["[拳头]"] = "$_emojiFilePath/拳头.png";
    /// 差劲
    _emojiMap["[爱你]"] = "$_emojiFilePath/爱你.png";
    _emojiMap["[NO]"] = "$_emojiFilePath/NO.png";
    _emojiMap["[OK]"] = "$_emojiFilePath/OK.png";
    _emojiMap["[爱情]"] = "$_emojiFilePath/爱情.png";
    /// 飞吻1
    /// 跳跳
    /// 发抖
    /// 怄火
    /// 转圈
    /// 磕头
    /// 回头
    /// 跳绳
    /// 挥手
    /// 激动3
    /// 街舞
    /// 献舞
    /// 左太极
    /// 右太极
  }
}

class EmotionPad extends StatefulWidget {
  final String route;
  final double height;
  EmotionPad(this.route, this.height, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EmotionPadState();
}

class EmotionPadState extends State<EmotionPad> {

  static double emoticonPadDefaultHeight = 260;
  static double emoticonPadHeight;
  static List<String> emoticonNames = [];
  static List<String> emoticonPaths = [];

  @override
  void initState() {
    super.initState();
    EmojiUtils.instance.emojiMap.forEach((name, path) {
      emoticonNames.add(name);
      emoticonPaths.add(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = max(emoticonPadDefaultHeight, widget.height);
    return Container(
        color: Theme.of(context).canvasColor,
        height: height,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8
            ),
            itemBuilder: (context, index) => Container(
                margin: EdgeInsets.all(4.0),
                child: IconButton(
                    icon: Image.asset(
                      emoticonPaths[index],
                      fit: BoxFit.fill,
                    ),
                    onPressed: () {
                      Constants.eventBus.fire(new AddEmoticonEvent(emoticonNames[index], widget.route));
                    }
                )
            ),
            itemCount: emoticonPaths.length
        )
    );
  }
}