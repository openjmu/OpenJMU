import 'dart:math';
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';

class EmoticonUtils {
  final Map<String, String> _emoticonMap = Map<String, String>();

  Map<String, String> get emoticonMap => _emoticonMap;

  final String _emoticonFilePath = "assets/emotionIcons";

  static EmoticonUtils _instance;
  static EmoticonUtils get instance {
    if (_instance == null) _instance = EmoticonUtils._();
    return _instance;
  }

  EmoticonUtils._() {
    _emoticonMap["[微笑2]"] = "$_emoticonFilePath/微笑2.png";
    _emoticonMap["[撇嘴1]"] = "$_emoticonFilePath/撇嘴1.png";
    _emoticonMap["[色4]"] = "$_emoticonFilePath/色4.png";
    _emoticonMap["[发呆2]"] = "$_emoticonFilePath/发呆2.png";
    _emoticonMap["[得意1]"] = "$_emoticonFilePath/得意1.png";
    _emoticonMap["[流泪2]"] = "$_emoticonFilePath/流泪2.png";
    _emoticonMap["[害羞5]"] = "$_emoticonFilePath/害羞5.png";
    _emoticonMap["[闭嘴1]"] = "$_emoticonFilePath/闭嘴1.png";
    _emoticonMap["[睡]"] = "$_emoticonFilePath/睡.png";
    _emoticonMap["[大哭7]"] = "$_emoticonFilePath/大哭7.png";
    _emoticonMap["[尴尬1]"] = "$_emoticonFilePath/尴尬1.png";
    _emoticonMap["[发怒]"] = "$_emoticonFilePath/发怒.png";
    _emoticonMap["[调皮1]"] = "$_emoticonFilePath/调皮1.png";
    _emoticonMap["[呲牙]"] = "$_emoticonFilePath/呲牙.png";
    _emoticonMap["[惊讶4]"] = "$_emoticonFilePath/惊讶4.png";
    _emoticonMap["[难过]"] = "$_emoticonFilePath/难过.png";
    _emoticonMap["[酷]"] = "$_emoticonFilePath/酷.png";
    _emoticonMap["[冷汗]"] = "$_emoticonFilePath/冷汗.png";
    _emoticonMap["[抓狂]"] = "$_emoticonFilePath/抓狂.png";
    _emoticonMap["[吐]"] = "$_emoticonFilePath/吐.png";
    _emoticonMap["[偷笑2]"] = "$_emoticonFilePath/偷笑2.png";
    _emoticonMap["[可爱1]"] = "$_emoticonFilePath/可爱1.png";
    _emoticonMap["[白眼1]"] = "$_emoticonFilePath/白眼1.png";
    _emoticonMap["[傲慢]"] = "$_emoticonFilePath/傲慢.png";
    _emoticonMap["[饥饿2]"] = "$_emoticonFilePath/饥饿2.png";
    _emoticonMap["[困]"] = "$_emoticonFilePath/困.png";
    _emoticonMap["[惊恐1]"] = "$_emoticonFilePath/惊恐1.png";
    _emoticonMap["[流汗2]"] = "$_emoticonFilePath/流汗2.png";
    _emoticonMap["[憨笑]"] = "$_emoticonFilePath/憨笑.png";
    _emoticonMap["[大兵]"] = "$_emoticonFilePath/大兵.png";

    /// 奋斗1
    _emoticonMap["[咒骂]"] = "$_emoticonFilePath/咒骂.png";
    _emoticonMap["[疑问2]"] = "$_emoticonFilePath/疑问2.png";
    _emoticonMap["[嘘]"] = "$_emoticonFilePath/嘘.png";
    _emoticonMap["[晕3]"] = "$_emoticonFilePath/晕3.png";
    _emoticonMap["[折磨1]"] = "$_emoticonFilePath/折磨1.png";
    _emoticonMap["[衰1]"] = "$_emoticonFilePath/衰1.png";
    _emoticonMap["[骷髅]"] = "$_emoticonFilePath/骷髅.png";

    /// 敲打
    _emoticonMap["[再见]"] = "$_emoticonFilePath/再见.png";

    /// 擦汗
    /// 抠鼻
    _emoticonMap["[鼓掌1]"] = "$_emoticonFilePath/鼓掌1.png";
    _emoticonMap["[糗大了]"] = "$_emoticonFilePath/糗大了.png";
    _emoticonMap["[坏笑1]"] = "$_emoticonFilePath/坏笑1.png";

    /// 左哼哼
    /// 右哼哼
    _emoticonMap["[哈欠]"] = "$_emoticonFilePath/哈欠.png";
    _emoticonMap["[鄙视2]"] = "$_emoticonFilePath/鄙视2.png";
    _emoticonMap["[委屈1]"] = "$_emoticonFilePath/委屈1.png";
    _emoticonMap["[快哭了]"] = "$_emoticonFilePath/快哭了.png";
    _emoticonMap["[阴险]"] = "$_emoticonFilePath/阴险.png";
    _emoticonMap["[亲亲]"] = "$_emoticonFilePath/亲亲.png";
    _emoticonMap["[吓]"] = "$_emoticonFilePath/吓.png";
    _emoticonMap["[可怜2]"] = "$_emoticonFilePath/可怜2.png";

    /// 菜刀
    _emoticonMap["[西瓜]"] = "$_emoticonFilePath/西瓜.png";
    _emoticonMap["[啤酒]"] = "$_emoticonFilePath/啤酒.png";
    _emoticonMap["[篮球]"] = "$_emoticonFilePath/篮球.png";
    _emoticonMap["[乒乓]"] = "$_emoticonFilePath/乒乓.png";
    _emoticonMap["[咖啡]"] = "$_emoticonFilePath/咖啡.png";
    _emoticonMap["[饭]"] = "$_emoticonFilePath/饭.png";
    _emoticonMap["[猪头]"] = "$_emoticonFilePath/猪头.png";
    _emoticonMap["[玫瑰]"] = "$_emoticonFilePath/玫瑰.png";
    _emoticonMap["[凋谢]"] = "$_emoticonFilePath/凋谢.png";
    _emoticonMap["[示爱]"] = "$_emoticonFilePath/示爱.png";
    _emoticonMap["[爱心]"] = "$_emoticonFilePath/爱心.png";
    _emoticonMap["[心碎]"] = "$_emoticonFilePath/心碎.png";
    _emoticonMap["[蛋糕]"] = "$_emoticonFilePath/蛋糕.png";
    _emoticonMap["[闪电]"] = "$_emoticonFilePath/闪电.png";
    _emoticonMap["[炸弹]"] = "$_emoticonFilePath/炸弹.png";
    _emoticonMap["[刀]"] = "$_emoticonFilePath/刀.png";
    _emoticonMap["[足球]"] = "$_emoticonFilePath/足球.png";
    _emoticonMap["[瓢虫]"] = "$_emoticonFilePath/瓢虫.png";
    _emoticonMap["[便便]"] = "$_emoticonFilePath/便便.png";
    _emoticonMap["[月亮]"] = "$_emoticonFilePath/月亮.png";
    _emoticonMap["[太阳]"] = "$_emoticonFilePath/太阳.png";
    _emoticonMap["[礼物]"] = "$_emoticonFilePath/礼物.png";
    _emoticonMap["[拥抱]"] = "$_emoticonFilePath/拥抱.png";
    _emoticonMap["[强]"] = "$_emoticonFilePath/强.png";
    _emoticonMap["[弱]"] = "$_emoticonFilePath/弱.png";
    _emoticonMap["[握手]"] = "$_emoticonFilePath/握手.png";
    _emoticonMap["[胜利]"] = "$_emoticonFilePath/胜利.png";
    _emoticonMap["[抱拳]"] = "$_emoticonFilePath/抱拳.png";

    /// 勾引
    _emoticonMap["[拳头]"] = "$_emoticonFilePath/拳头.png";

    /// 差劲
    _emoticonMap["[爱你]"] = "$_emoticonFilePath/爱你.png";
    _emoticonMap["[NO]"] = "$_emoticonFilePath/NO.png";
    _emoticonMap["[OK]"] = "$_emoticonFilePath/OK.png";
    _emoticonMap["[爱情]"] = "$_emoticonFilePath/爱情.png";

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
  static double emoticonPadDefaultHeight = Constants.suSetSp(260);
  static double emoticonPadHeight;
  static List<String> emoticonNames = [];
  static List<String> emoticonPaths = [];

  @override
  void initState() {
    super.initState();
    EmoticonUtils.instance.emoticonMap.forEach((name, path) {
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
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.all(Constants.suSetSp(4.0)),
          child: IconButton(
            icon: Image.asset(
              emoticonPaths[index],
              fit: BoxFit.fill,
            ),
            onPressed: () {
              Instances.eventBus
                  .fire(AddEmoticonEvent(emoticonNames[index], widget.route));
            },
          ),
        ),
        itemCount: emoticonPaths.length,
      ),
    );
  }
}
