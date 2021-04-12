import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

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

  static double get padDefaultHeight => Screens.width / padGridCount * 5;

  static int get padGridCount => 7;

  @override
  _EmojiPadState createState() => _EmojiPadState();
}

class _EmojiPadState extends State<EmojiPad> {
  List<EmojiModel> recentEmojis;

  void fetchRecentEmojis() {
    final List<EmojiModel> _emojis =
        HiveBoxes.emojisBox.get(currentUser.uid)?.cast<EmojiModel>();
    if (_emojis?.isNotEmpty == true) {
      recentEmojis = _emojis;
    } else {
      final List<EmojiModel> _sublist = emojis.sublist(0, 7);
      recentEmojis = _sublist;
      HiveBoxes.emojisBox.put(currentUser.uid, _sublist);
    }
  }

  void addRecentEmojiModel(EmojiModel emoji) {
    final List<EmojiModel> _emojis = List<EmojiModel>.of(
      HiveBoxes.emojisBox.get(currentUser.uid)?.cast<EmojiModel>(),
    );
    if (_emojis.contains(emoji)) {
      _emojis.remove(emoji);
    } else {
      _emojis.removeAt(0);
    }
    _emojis.add(emoji);
    HiveBoxes.emojisBox.put(currentUser.uid, _emojis);
  }

  Widget _itemBuilder(
    BuildContext context,
    int index, {
    Iterable<EmojiModel> list,
  }) {
    final EmojiModel emoji = (list ?? emojis).elementAt(index);
    return Tapper(
      onTap: () {
        addRecentEmojiModel(emoji);
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

const List<EmojiModel> emojis = <EmojiModel>[
  EmojiModel(name: 'doge', filename: 'doge'),
  EmojiModel(name: '滑稽', filename: 'huaji'),
  EmojiModel(name: '666', filename: '666'),
  EmojiModel(name: '暗中观察', filename: 'anzhongguancha'),
  EmojiModel(name: '沧桑', filename: 'cangsang'),
  EmojiModel(name: '打脸', filename: 'dalian'),
  EmojiModel(name: '机智', filename: 'jizhi'),
  EmojiModel(name: '防疫', filename: 'fangyi'),
  EmojiModel(name: '笑哭', filename: 'xiaoku'),
  EmojiModel(name: '捂脸', filename: 'wulian'),
  EmojiModel(name: '苦涩', filename: 'kuse'),
  EmojiModel(name: '摸鱼', filename: 'moyu'),
  EmojiModel(name: '柠檬', filename: 'ningmeng'),
  EmojiModel(name: '压岁钱', filename: 'yasuiqian'),
  EmojiModel(name: '福字', filename: 'fuzi'),
  EmojiModel(name: '灯笼', filename: 'denglong'),
  EmojiModel(name: '烟火', filename: 'yanhuo'),
  EmojiModel(name: '鞭炮', filename: 'bianpao'),
  EmojiModel(name: '微笑', text: '微笑2', filename: 'weixiao2'),
  EmojiModel(name: '撇嘴', text: '撇嘴1', filename: 'piezui1'),
  EmojiModel(name: '色', text: '色4', filename: 'se4'),
  EmojiModel(name: '发呆', text: '发呆2', filename: 'fadai2'),
  EmojiModel(name: '得意', text: '得意1', filename: 'deyi1'),
  EmojiModel(name: '流泪', text: '流泪2', filename: 'liulei2'),
  EmojiModel(name: '害羞', text: '害羞5', filename: 'haixiu5'),
  EmojiModel(name: '闭嘴', text: '闭嘴1', filename: 'bizui1'),
  EmojiModel(name: '睡', filename: 'shui'),
  EmojiModel(name: '大哭', text: '大哭7', filename: 'daku7'),
  EmojiModel(name: '尴尬', text: '尴尬1', filename: 'ganga1'),
  EmojiModel(name: '发怒', filename: 'fanu'),
  EmojiModel(name: '调皮', text: '调皮1', filename: 'tiaopi1'),
  EmojiModel(name: '呲牙', filename: 'ciya'),
  EmojiModel(name: '惊讶', text: '惊讶4', filename: 'jingya4'),
  EmojiModel(name: '难过', filename: 'nanguo'),
  EmojiModel(name: '酷', filename: 'ku'),
  EmojiModel(name: '冷汗', filename: 'lenghan'),
  EmojiModel(name: '抓狂', filename: 'zhuakuang'),
  EmojiModel(name: '吐', filename: 'tu'),
  EmojiModel(name: '偷笑', text: '偷笑2', filename: 'touxiao2'),
  EmojiModel(name: '可爱', text: '可爱1', filename: 'keai1'),
  EmojiModel(name: '白眼', text: '白眼1', filename: 'baiyan1'),
  EmojiModel(name: '傲慢', filename: 'aoman'),
  EmojiModel(name: '饥饿', text: '饥饿2', filename: 'jie2'),
  EmojiModel(name: '困', filename: 'kun'),
  EmojiModel(name: '惊恐', text: '惊恐1', filename: 'jingkong1'),
  EmojiModel(name: '流汗', text: '流汗2', filename: 'liuhan2'),
  EmojiModel(name: '憨笑', filename: 'hanxiao'),
  EmojiModel(name: '大兵', filename: 'dabing'),
  EmojiModel(name: '奋斗', text: '奋斗1', filename: 'fendou1'),
  EmojiModel(name: '咒骂', filename: 'zhouma'),
  EmojiModel(name: '疑问', text: '疑问2', filename: 'yiwen2'),
  EmojiModel(name: '嘘', filename: 'xu'),
  EmojiModel(name: '晕', text: '晕3', filename: 'yun3'),
  EmojiModel(name: '折磨', text: '折磨1', filename: 'zhemo1'),
  EmojiModel(name: '衰', text: '衰1', filename: 'shuai1'),
  EmojiModel(name: '骷髅', filename: 'kulou'),
  EmojiModel(name: '敲打', filename: 'qiaoda'),
  EmojiModel(name: '再见', filename: 'zaijian'),
  EmojiModel(name: '擦汗', filename: 'cahan'),
  EmojiModel(name: '抠鼻', filename: 'koubi'),
  EmojiModel(name: '鼓掌', text: '鼓掌1', filename: 'guzhang1'),
  EmojiModel(name: '糗大了', filename: 'qiudale'),
  EmojiModel(name: '坏笑', text: '坏笑1', filename: 'huaixiao1'),
  EmojiModel(name: '左哼哼', filename: 'zuohengheng'),
  EmojiModel(name: '右哼哼', filename: 'youhengheng'),
  EmojiModel(name: '哈欠', filename: 'haqian'),
  EmojiModel(name: '鄙视', text: '鄙视2', filename: 'bishi2'),
  EmojiModel(name: '委屈', text: '委屈1', filename: 'weiqu1'),
  EmojiModel(name: '快哭了', filename: 'kuaikule'),
  EmojiModel(name: '阴险', filename: 'yinxian'),
  EmojiModel(name: '亲亲', filename: 'qinqin'),
  EmojiModel(name: '吓', filename: 'xia'),
  EmojiModel(name: '可怜', text: '可怜2', filename: 'kelian2'),
  EmojiModel(name: '菜刀', filename: 'caidao'),
  EmojiModel(name: '西瓜', filename: 'xigua'),
  EmojiModel(name: '啤酒', filename: 'pijiu'),
  EmojiModel(name: '篮球', filename: 'lanqiu'),
  EmojiModel(name: '乒乓', filename: 'pingpang'),
  EmojiModel(name: '咖啡', filename: 'kafei'),
  EmojiModel(name: '饭', filename: 'fan'),
  EmojiModel(name: '猪头', filename: 'zhutou'),
  EmojiModel(name: '玫瑰', filename: 'meigui'),
  EmojiModel(name: '凋谢', filename: 'diaoxie'),
  EmojiModel(name: '示爱', filename: 'shiai'),
  EmojiModel(name: '爱心', filename: 'aixin'),
  EmojiModel(name: '心碎', filename: 'xinsui'),
  EmojiModel(name: '蛋糕', filename: 'dangao'),
  EmojiModel(name: '闪电', filename: 'shandian'),
  EmojiModel(name: '炸弹', filename: 'zhadan'),
  EmojiModel(name: '刀', filename: 'dao'),
  EmojiModel(name: '足球', filename: 'zuqiu'),
  EmojiModel(name: '瓢虫', filename: 'piaochong'),
  EmojiModel(name: '便便', filename: 'bianbian'),
  EmojiModel(name: '月亮', filename: 'yueliang'),
  EmojiModel(name: '太阳', filename: 'taiyang'),
  EmojiModel(name: '礼物', filename: 'liwu'),
  EmojiModel(name: '拥抱', filename: 'yongbao'),
  EmojiModel(name: '强', filename: 'qiang'),
  EmojiModel(name: '弱', filename: 'ruo'),
  EmojiModel(name: '握手', filename: 'woshou'),
  EmojiModel(name: '胜利', filename: 'shengli'),
  EmojiModel(name: '抱拳', filename: 'baoquan'),
  EmojiModel(name: '勾引', filename: 'gouyin'),
  EmojiModel(name: '拳头', filename: 'quantou'),
  EmojiModel(name: '差劲', filename: 'chajin'),
  EmojiModel(name: '爱你', filename: 'aini'),
  EmojiModel(name: 'NO', filename: 'NO'),
  EmojiModel(name: 'OK', filename: 'OK'),
  EmojiModel(name: '爱情', filename: 'aiqing'),
  EmojiModel(name: '飞吻', text: '飞吻1', filename: 'feiwen1'),
  EmojiModel(name: '跳跳', filename: 'tiaotiao'),
  EmojiModel(name: '发抖', filename: 'fadou'),
  EmojiModel(name: '怄火', filename: 'ouhuo'),
  EmojiModel(name: '转圈', filename: 'zhuanquan'),
  EmojiModel(name: '磕头', filename: 'ketou'),
  EmojiModel(name: '回头', filename: 'huitou'),
  EmojiModel(name: '跳绳', filename: 'tiaosheng'),
  EmojiModel(name: '挥手', filename: 'zaijian'),
  EmojiModel(name: '激动', text: '激动3', filename: 'jidong3'),
  EmojiModel(name: '街舞', filename: 'jiewu'),
  EmojiModel(name: '献吻', filename: 'xianwen'),
  EmojiModel(name: '左太极', filename: 'zuotaiji'),
  EmojiModel(name: '右太极', filename: 'youtaiji'),
];

extension EmojiListExtension on List<EmojiModel> {
  EmojiModel fromText(String text) =>
      where((EmojiModel e) => e.wrappedText == text).first;

  bool containsText(String text) =>
      any((EmojiModel e) => e.wrappedText == text);
}
