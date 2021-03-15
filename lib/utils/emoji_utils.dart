import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:openjmu/constants/constants.dart';

@immutable
@HiveType(typeId: HiveAdapterTypeIds.emoji)
class Emoji extends Equatable {
  const Emoji({
    @required this.name,
    @required this.filename,
    String text,
  }) : _text = text ?? name;

  static const String dir = 'assets/emoji';

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String filename;
  @HiveField(2)
  final String _text;

  String get text => _text;

  String get wrappedText => '[$_text]';

  String get path => '$dir/$filename.png';

  @override
  List<Object> get props => <Object>[name, _text, filename];

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'text': _text,
      'filename': filename,
    };
  }
}

class EmojiPad extends StatefulWidget {
  const EmojiPad({
    Key key,
    @required this.active,
    @required this.height,
    this.controller,
  }) : super(key: key);

  final bool active;
  final double height;
  final TextEditingController controller;

  static double get padDefaultHeight => Screens.width / padGridCount * 4;

  static int get padGridCount => 7;

  @override
  _EmojiPadState createState() => _EmojiPadState();
}

class _EmojiPadState extends State<EmojiPad> {
  List<Emoji> recentEmojis;

  void fetchRecentEmojis() {
    final List<Emoji> _emojis =
        HiveBoxes.emojisBox.get(currentUser.uid)?.cast<Emoji>();
    if (_emojis?.isNotEmpty == true) {
      recentEmojis = _emojis;
    } else {
      final List<Emoji> _sublist = emojis.sublist(0, 7);
      recentEmojis = _sublist;
      HiveBoxes.emojisBox.put(currentUser.uid, _sublist);
    }
  }

  void addRecentEmoji(Emoji emoji) {
    final List<Emoji> _emojis = List<Emoji>.of(
      HiveBoxes.emojisBox.get(currentUser.uid)?.cast<Emoji>(),
    );
    if (_emojis.contains(emoji)) {
      _emojis.remove(emoji);
    } else {
      _emojis.removeAt(0);
    }
    _emojis.add(emoji);
    HiveBoxes.emojisBox.put(currentUser.uid, _emojis);
  }

  Widget _itemBuilder(BuildContext context, int index, {Iterable<Emoji> list}) {
    final Emoji emoji = (list ?? emojis).elementAt(index);
    return Tapper(
      onTap: () {
        addRecentEmoji(emoji);
        InputUtils.insertText(
          text: emoji.wrappedText,
          controller: widget.controller,
        );
      },
      child: Center(
        child: RepaintBoundary(
          child: Image.asset(
            emoji.path,
            fit: BoxFit.contain,
            width: Screens.width / EmojiPad.padGridCount / 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchRecentEmojis();
    final double _height = math.max(EmojiPad.padDefaultHeight, widget.height);
    return Container(
      height: widget.active ? _height : 0,
      decoration: BoxDecoration(
        border: Border(top: dividerBS(context)),
        color: context.theme.canvasColor,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
              child: Text(
                '最近使用',
                style: context.textTheme.caption.copyWith(fontSize: 19.sp),
              ),
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (BuildContext c, int i) => _itemBuilder(
                c,
                i,
                list: recentEmojis.reversed,
              ),
              childCount: 7,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.25,
              crossAxisCount: EmojiPad.padGridCount,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
              child: Text(
                '全部表情',
                style: context.textTheme.caption.copyWith(fontSize: 19.sp),
              ),
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              _itemBuilder,
              childCount: emojis.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.25,
              crossAxisCount: EmojiPad.padGridCount,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '表情来自',
                    style: context.textTheme.caption.copyWith(
                      fontSize: 18.sp,
                      height: 1.2,
                    ),
                  ),
                  Gap(8.w),
                  SvgPicture.asset(
                    R.ASSETS_ICONS_JIMOJITAG_SVG,
                    color: context.textTheme.caption.color,
                    height: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Emoji> emojis = <Emoji>[
  Emoji(name: 'doge', filename: 'doge'),
  Emoji(name: '滑稽', filename: 'huaji'),
  Emoji(name: '666', filename: '666'),
  Emoji(name: '暗中观察', filename: 'anzhongguancha'),
  Emoji(name: '沧桑', filename: 'cangsang'),
  Emoji(name: '打脸', filename: 'dalian'),
  Emoji(name: '机智', filename: 'jizhi'),
  Emoji(name: '防疫', filename: 'fangyi'),
  Emoji(name: '笑哭', filename: 'xiaoku'),
  Emoji(name: '捂脸', filename: 'wulian'),
  Emoji(name: '苦涩', filename: 'kuse'),
  Emoji(name: '摸鱼', filename: 'moyu'),
  Emoji(name: '柠檬', filename: 'ningmeng'),
  Emoji(name: '压岁钱', filename: 'yasuiqian'),
  Emoji(name: '福字', filename: 'fuzi'),
  Emoji(name: '灯笼', filename: 'denglong'),
  Emoji(name: '烟火', filename: 'yanhuo'),
  Emoji(name: '鞭炮', filename: 'bianpao'),
  Emoji(name: '微笑', text: '微笑2', filename: 'weixiao2'),
  Emoji(name: '撇嘴', text: '撇嘴1', filename: 'piezui1'),
  Emoji(name: '色', text: '色4', filename: 'se4'),
  Emoji(name: '发呆', text: '发呆2', filename: 'fadai2'),
  Emoji(name: '得意', text: '得意1', filename: 'deyi1'),
  Emoji(name: '流泪', text: '流泪2', filename: 'liulei2'),
  Emoji(name: '害羞', text: '害羞5', filename: 'haixiu5'),
  Emoji(name: '闭嘴', text: '闭嘴1', filename: 'bizui1'),
  Emoji(name: '睡', filename: 'shui'),
  Emoji(name: '大哭', text: '大哭7', filename: 'daku7'),
  Emoji(name: '尴尬', text: '尴尬1', filename: 'ganga1'),
  Emoji(name: '发怒', filename: 'fanu'),
  Emoji(name: '调皮', text: '调皮1', filename: 'tiaopi1'),
  Emoji(name: '呲牙', filename: 'ciya'),
  Emoji(name: '惊讶', text: '惊讶4', filename: 'jingya4'),
  Emoji(name: '难过', filename: 'nanguo'),
  Emoji(name: '酷', filename: 'ku'),
  Emoji(name: '冷汗', filename: 'lenghan'),
  Emoji(name: '抓狂', filename: 'zhuakuang'),
  Emoji(name: '吐', filename: 'tu'),
  Emoji(name: '偷笑', text: '偷笑2', filename: 'touxiao2'),
  Emoji(name: '可爱', text: '可爱1', filename: 'keai1'),
  Emoji(name: '白眼', text: '白眼1', filename: 'baiyan1'),
  Emoji(name: '傲慢', filename: 'aoman'),
  Emoji(name: '饥饿', text: '饥饿2', filename: 'jie2'),
  Emoji(name: '困', filename: 'kun'),
  Emoji(name: '惊恐', text: '惊恐1', filename: 'jingkong1'),
  Emoji(name: '流汗', text: '流汗2', filename: 'liuhan2'),
  Emoji(name: '憨笑', filename: 'hanxiao'),
  Emoji(name: '大兵', filename: 'dabing'),
  Emoji(name: '奋斗', text: '奋斗1', filename: 'fendou1'),
  Emoji(name: '咒骂', filename: 'zhouma'),
  Emoji(name: '疑问', text: '疑问2', filename: 'yiwen2'),
  Emoji(name: '嘘', filename: 'xu'),
  Emoji(name: '晕', text: '晕3', filename: 'yun3'),
  Emoji(name: '折磨', text: '折磨1', filename: 'zhemo1'),
  Emoji(name: '衰', text: '衰1', filename: 'shuai1'),
  Emoji(name: '骷髅', filename: 'kulou'),
  Emoji(name: '敲打', filename: 'qiaoda'),
  Emoji(name: '再见', filename: 'zaijian'),
  Emoji(name: '擦汗', filename: 'cahan'),
  Emoji(name: '抠鼻', filename: 'koubi'),
  Emoji(name: '鼓掌', text: '鼓掌1', filename: 'guzhang1'),
  Emoji(name: '糗大了', filename: 'qiudale'),
  Emoji(name: '坏笑', text: '坏笑1', filename: 'huaixiao1'),
  Emoji(name: '左哼哼', filename: 'zuohengheng'),
  Emoji(name: '右哼哼', filename: 'youhengheng'),
  Emoji(name: '哈欠', filename: 'haqian'),
  Emoji(name: '鄙视', text: '鄙视2', filename: 'bishi2'),
  Emoji(name: '委屈', text: '委屈1', filename: 'weiqu1'),
  Emoji(name: '快哭了', filename: 'kuaikule'),
  Emoji(name: '阴险', filename: 'yinxian'),
  Emoji(name: '亲亲', filename: 'qinqin'),
  Emoji(name: '吓', filename: 'xia'),
  Emoji(name: '可怜', text: '可怜2', filename: 'kelian2'),
  Emoji(name: '菜刀', filename: 'caidao'),
  Emoji(name: '西瓜', filename: 'xigua'),
  Emoji(name: '啤酒', filename: 'pijiu'),
  Emoji(name: '篮球', filename: 'lanqiu'),
  Emoji(name: '乒乓', filename: 'pingpang'),
  Emoji(name: '咖啡', filename: 'kafei'),
  Emoji(name: '饭', filename: 'fan'),
  Emoji(name: '猪头', filename: 'zhutou'),
  Emoji(name: '玫瑰', filename: 'meigui'),
  Emoji(name: '凋谢', filename: 'diaoxie'),
  Emoji(name: '示爱', filename: 'shiai'),
  Emoji(name: '爱心', filename: 'aixin'),
  Emoji(name: '心碎', filename: 'xinsui'),
  Emoji(name: '蛋糕', filename: 'dangao'),
  Emoji(name: '闪电', filename: 'shandian'),
  Emoji(name: '炸弹', filename: 'zhadan'),
  Emoji(name: '刀', filename: 'dao'),
  Emoji(name: '足球', filename: 'zuqiu'),
  Emoji(name: '瓢虫', filename: 'piaochong'),
  Emoji(name: '便便', filename: 'bianbian'),
  Emoji(name: '月亮', filename: 'yueliang'),
  Emoji(name: '太阳', filename: 'taiyang'),
  Emoji(name: '礼物', filename: 'liwu'),
  Emoji(name: '拥抱', filename: 'yongbao'),
  Emoji(name: '强', filename: 'qiang'),
  Emoji(name: '弱', filename: 'ruo'),
  Emoji(name: '握手', filename: 'woshou'),
  Emoji(name: '胜利', filename: 'shengli'),
  Emoji(name: '抱拳', filename: 'baoquan'),
  Emoji(name: '勾引', filename: 'gouyin'),
  Emoji(name: '拳头', filename: 'quantou'),
  Emoji(name: '差劲', filename: 'chajin'),
  Emoji(name: '爱你', filename: 'aini'),
  Emoji(name: 'NO', filename: 'NO'),
  Emoji(name: 'OK', filename: 'OK'),
  Emoji(name: '爱情', filename: 'aiqing'),
  Emoji(name: '飞吻', text: '飞吻1', filename: 'feiwen1'),
  Emoji(name: '跳跳', filename: 'tiaotiao'),
  Emoji(name: '发抖', filename: 'fadou'),
  Emoji(name: '怄火', filename: 'ouhuo'),
  Emoji(name: '转圈', filename: 'zhuanquan'),
  Emoji(name: '磕头', filename: 'ketou'),
  Emoji(name: '回头', filename: 'huitou'),
  Emoji(name: '跳绳', filename: 'tiaosheng'),
  Emoji(name: '挥手', filename: 'zaijian'),
  Emoji(name: '激动', text: '激动3', filename: 'jidong3'),
  Emoji(name: '街舞', filename: 'jiewu'),
  Emoji(name: '献吻', filename: 'xianwen'),
  Emoji(name: '左太极', filename: 'zuotaiji'),
  Emoji(name: '右太极', filename: 'youtaiji'),
];

extension EmojiListExtension on List<Emoji> {
  Emoji fromText(String text) =>
      where((Emoji e) => e.wrappedText == text).first;

  bool containsText(String text) => any((Emoji e) => e.wrappedText == text);
}
