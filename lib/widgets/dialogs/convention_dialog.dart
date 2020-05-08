///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 07:30
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart';

class ConventionDialog extends StatefulWidget {
  static Future<bool> show(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => ConventionDialog(),
        barrierDismissible: false,
      );

  @override
  _ConventionDialogState createState() => _ConventionDialogState();
}

class _ConventionDialogState extends State<ConventionDialog> {
  Timer countDownTimer;
  int countDown = 5;

  bool get canSend => countDown == 0;

  @override
  void initState() {
    super.initState();
    countDownTimer = Timer.periodic(1.seconds, (Timer timer) {
      --countDown;
      if (countDown == 0) {
        cancelTimer();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  void cancelTimer() {
    countDownTimer?.cancel();
    countDownTimer = null;
  }

  Widget get header => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(16.0), vertical: suSetHeight(20.0)),
        child: Center(
          child: Text(
            '发布提醒',
            style:
                TextStyle(fontSize: suSetSp(23.0), fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget get confirmTips => Text.rich(
        TextSpan(children: <InlineSpan>[
          TextSpan(text: '发布动态前，请确认您已阅读并知晓'),
          TextSpan(
            text: '《集大通平台公约》',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '，且发布的内容符合公约要求。'),
        ]),
        style: TextStyle(
          fontSize: suSetSp(18.0),
          fontWeight: FontWeight.normal,
        ),
      );

  Widget get conventionTitle => Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(12.0)),
        child: Text(
          '集大通平台公约',
          style: TextStyle(
            fontSize: suSetSp(20.0),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );

  Widget get conventionContent => Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '　集大通平台广告泛滥、不宜帖子频现，'
                  '给用户正常浏览带来了严重影响，'
                  '为了消除此现象带来的不良用户体验，'
                  '拟进一步加强和规范集大通平台的管理措施。规定如下：\n',
            ),
            TextSpan(
              text: '一、集大通平台全区\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '　禁止发布以下内容信息，形式包括但不限于文字、图片、链接、二维码：\n',
            ),
            TextSpan(
              text: '　1、 违反法律法规、公序良俗及学校规章制度的信息，'
                  '包括但不限于\n'
                  '　(1) 违反宪法确定的基本原则的；\n'
                  '　(2) 危害国家安全、泄漏国家机密、颠覆国家政权，破坏国家统一的；\n'
                  '　(3) 损害国家荣誉和利益的；\n'
                  '　(4) 煽动民族仇恨、民族歧视，破坏民族团结的\n'
                  '　(5) 破坏国家宗教政策、宣扬邪教和封建迷信的；\n'
                  '　(6) 散布谣言，扰乱社会秩序、破坏社会稳定的；\n'
                  '　(7) 散布淫秽、色情、赌博、暴力、恐怖或者教唆犯罪的；\n'
                  '　(8) 侮辱或者诽谤他人，侵害他人合法权益的；\n'
                  '　(9) 煽动非法集会、结社、游行、示威、聚众扰乱社会秩序的；\n'
                  '　(10) 以非法民间组织名义活动的；\n'
                  '　(11) 含有法律、法规、规章、地方规范性文件、'
                  '国家政策、政府通知、公序良俗等禁止的内容；\n'
                  '　(12) 本平台认为不利于平台生态、可能给平台造成损失的内容。\n',
            ),
            TextSpan(
              text: '　2、针对特定用户或群体（包括但不限于种族、国籍、'
                  '宗教信仰、政治立场、身份职业、出身地区、兴趣爱好），'
                  '发布具有挑衅性质、攻击性质（包括但不限于明示与暗示的歧视、'
                  '嘲讽、贬低、挑衅、辱骂）的内容，或存在煽动他人进行上述行为的情况；\n',
            ),
            TextSpan(
              text: '　3、单一用户或多用户恶意在短时间内发送多条相同或者类似内容，'
                  '包括但不限于刷屏、灌水、刷评论，但在某些活动的气氛烘托下，'
                  '多用户发送相同内容，属于共同的情感表达，不属于恶意刷屏\n',
            ),
            TextSpan(
              text: '二、微博广场首页\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '　1、禁止发布链接、二维码。用户若是需要在微博广场首页发布合规的链接、二维码，'
                  '如用于课题研究的问卷调查、教程、统一考试的报名查询链接等，'
                  '需要向“集大阿通”报备审核后方可发布。\n',
            ),
            TextSpan(
              text: '　2、禁止发布以下内容信息，形式包括但不限于文字、图片：'
                  '任何性质的广告，包括但不限于兼职、招聘、家教、赞助、拼单、'
                  '票务、加盟、有偿回收、买卖物品、二手交易、电话卡推广、'
                  '团建推广、培训机构推广、志愿者招募、创业实践广告、有偿服务、'
                  '非校内注册组织宣传、红包码、平台推广码或链接，'
                  '以及请求以上内容的信息。\n',
            ),
            TextSpan(
              text: '　用户若需要发布此类信息，请移步',
            ),
            TextSpan(
              text: 'OpenJMU中的“集市”',
              style: TextStyle(
                fontSize: suSetSp(20.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '区。微博广场仅供用户发布生活动态、心得分享等普通消息，'
                  '以及官方组织发布通知公告、校内注册的社团协会/部门发布不含赞助信息的宣传。\n',
            ),
            TextSpan(
              text: '三、违反公约的处罚规定：\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '　1、违反规定的帖子，发现后将予屏蔽；\n',
            ),
            TextSpan(
              text: '　2、再次违规者，将予禁言一周；\n',
            ),
            TextSpan(
              text: '　3、严重违规者，将予无限期禁言；\n',
            ),
            TextSpan(
              text: '　4、对于频频违规或严重违规发帖的同学，以及涉及前述“一、中的1.和2.”的同学，'
                  '将报请辅导员协助处理，若不知悔改，将禁止其使用集大通/OpenJMU。\n',
            ),
            TextSpan(
              text: '　用户被禁言期满后，需经个人申请（私信“网络中心用户服务”帐号，保证不再违规）方能解禁。'
                  '被无限期禁言者至少须在三个月后经书面申请，经确认认识到位后方可解禁，'
                  '认识不到位者不能解禁。禁言不影响集大通其他功能的使用。\n',
            ),
            TextSpan(
              text: '四、有效举报的奖励：\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '　对于有效举报将以送花作为奖励。\n',
            ),
            TextSpan(
              text: '　举报方法：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '点击内容右上角的按钮，点击“举报动态”。\n',
            ),
            TextSpan(
              text: '\n　如有更好的建议，欢迎私信“网络中心用户服务”帐号'
                  '（关注办法详见：',
            ),
            TextSpan(
              text: 'http://net.jmu.edu.cn/info/1309/2518.htm',
              style: TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  API.launchWeb(
                      url: 'http://net.jmu.edu.cn/info/1309/2518.htm');
                },
            ),
            TextSpan(
              text: '），期待大家共同维护我们良好和谐的校园网络社交环境。',
            ),
          ],
        ),
        style: TextStyle(
          fontSize: suSetSp(18.0),
          fontWeight: FontWeight.normal,
        ),
      );

  Widget actions(BuildContext context) => Padding(
        padding: EdgeInsets.all(suSetWidth(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            confirmButton(context),
            SizedBox(width: suSetWidth(16.0)),
            cancelButton(context),
          ],
        ),
      );

  Widget confirmButton(BuildContext context) => Expanded(
        flex: 5,
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: 2.0,
          height: suSetHeight(56.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.w),
          ),
          color: context.themeData.canvasColor,
          onPressed: canSend ? () {
            Navigator.of(context).pop(true);
          } : null,
          child: Text(
            () {
              final String s = '确认无误';
              if (canSend) {
                return s;
              } else {
                return '$s(${countDown}s)';
              }
            }(),
            style: TextStyle(fontSize: suSetSp(21.0)),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  Widget cancelButton(BuildContext context) => Expanded(
        flex: 5,
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: 2.0,
          height: suSetHeight(56.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          ),
          color: currentThemeColor.withOpacity(0.8),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            '我再想想',
            style: TextStyle(color: Colors.white, fontSize: suSetSp(21.0)),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetWidth(20.0)),
          child: Container(
            width: Screens.width * 0.75,
            height: Screens.height * 0.7,
            color: currentIsDark
                ? Theme.of(context).canvasColor
                : Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                header,
                Expanded(
                  child: Container(
                    color: currentIsDark
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).canvasColor,
                    child: CupertinoScrollbar(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: suSetWidth(20.0),
                          vertical: suSetHeight(10.0),
                        ),
                        children: <Widget>[
                          confirmTips,
                          conventionTitle,
                          conventionContent
                        ],
                      ),
                    ),
                  ),
                ),
                actions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
