///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 07:30
///
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class ConventionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: EdgeInsets.all(suSetWidth(20.0)),
          width: Screen.width * 0.8,
          height: Screen.height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(20.0)),
            color: Color.lerp(
              Theme.of(context).cardColor,
              ThemeUtils.currentThemeColor,
              0.2,
            ),
          ),
          child: CupertinoScrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      bottom: suSetHeight(20.0),
                    ),
                    child: Text(
                      "集大通平台公约",
                      style: TextStyle(
                        fontSize: suSetSp(26.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "　集大通平台广告泛滥、不宜帖子频现，给用户正常浏览带来了严重影响"
                              "为了消除此现象带来的不良用户体验，拟进一步加强和规范集大通平台的管理措施。"
                              "规定如下：\n",
                        ),
                        TextSpan(
                          text: "　1、",
                        ),
                        TextSpan(
                          text: "集大通平台全区",
                          style: TextStyle(
                            fontSize: suSetSp(23.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "禁止发布以下内容信息：\n",
                        ),
                        TextSpan(
                          text: "　① 违反法律法规、公序良俗和学校规章制度的信息。"
                              "包括但不限于发送色情、赌博、诈骗、不实信息、非法网站等信息；\n",
                        ),
                        TextSpan(
                          text: "　② 针对其他用户的谩骂、羞辱、嘲讽；\n",
                        ),
                        TextSpan(
                          text:
                              "　③ 针对特定群体（包括但不限于：种族、国籍、宗教信仰、政治立场、身份职业、出身地区、兴趣爱好等），"
                              "发布具有挑衅性质、攻击性质（包括但不限于明示与暗示的歧视、嘲讽、贬低、挑衅、辱骂等）的内容，"
                              "或存在煽动他人进行上述行为的情况；\n",
                        ),
                        TextSpan(
                          text: "　④ 单一用户恶意在短时间内发送多条相同或者类似内容，"
                              "但在某些活动的气氛烘托下，多用户发送相同内容，"
                              "属于共同的情感表达，不属于恶意刷屏。\n",
                        ),
                        TextSpan(
                          text: "　2、",
                        ),
                        TextSpan(
                          text: "微博广场首页",
                          style: TextStyle(
                            fontSize: suSetSp(23.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "禁止发布以下内容信息：\n",
                        ),
                        TextSpan(
                          text: "　任何性质的广告，如兼职、招聘、家教、刷单、买卖物品、"
                              "二手交易、志愿者招募、创业实践广告、有偿服务等内容。\n",
                        ),
                        TextSpan(
                          text: "　若需要发布此类信息，请移步",
                        ),
                        TextSpan(
                          text: "集大通的“课余生活->二手市场”",
                          style: TextStyle(
                            fontSize: suSetSp(20.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "或者",
                        ),
                        TextSpan(
                          text: "OpenJMU中的“集市”",
                          style: TextStyle(
                            fontSize: suSetSp(20.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "区。微博广场仅供用户发布生活动态、心得分享等普通消息，"
                              "以及官方组织发布通知公告。\n",
                        ),
                        TextSpan(
                          text: "　3、",
                        ),
                        TextSpan(
                          text: "违反公约",
                          style: TextStyle(
                            fontSize: suSetSp(23.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "的处罚规定：\n",
                        ),
                        TextSpan(
                          text: "　① 违反规定的帖子，发现后将予屏蔽；\n",
                        ),
                        TextSpan(
                          text: "　② 再次违规者，将予禁言一周；\n",
                        ),
                        TextSpan(
                          text: "　③ 严重违规者，将予无限期禁言；\n",
                        ),
                        TextSpan(
                          text: "　④ 对于频频违规或严重违规发帖的同学，将报请辅导员协助处理。\n",
                        ),
                        TextSpan(
                          text: "　用户被禁言期满后，需经个人申请（私信“网络中心用户服务”帐号，保证不再违规）方能解禁。"
                              "被无限期禁言者至少须在三个月后经书面申请，经确认认识到位后方可解禁，"
                              "认识不到位者不能解禁。禁言不影响集大通其他功能的使用。\n",
                        ),
                        TextSpan(
                          text: "　4、",
                        ),
                        TextSpan(
                          text: "有效举报",
                          style: TextStyle(
                            fontSize: suSetSp(23.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "的奖励：\n",
                        ),
                        TextSpan(
                          text: "　对于有效举报将以送花作为奖励。\n",
                        ),
                        TextSpan(
                          text: "　举报方法：",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "点击该条内容右上角的按钮，点击“举报动态”。\n",
                        ),
                        TextSpan(
                          text: "\n　如有更好的建议，欢迎私信“网络中心用户服务”帐号"
                              "（关注办法详见：",
                        ),
                        TextSpan(
                          text: "http://net.jmu.edu.cn/info/1309/2518.htm",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              CommonWebPage.jump(
                                "http://net.jmu.edu"
                                    ".cn/info/1309/2518.htm",
                                "",
                              );
                            },
                        ),
                        TextSpan(
                          text: "），期待大家共同维护我们良好和谐的校园网络社交环境。",
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: suSetSp(18.0),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
