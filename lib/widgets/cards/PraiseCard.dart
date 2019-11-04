import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/pages/post/PostDetailPage.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class PraiseCard extends StatelessWidget {
  final Praise praise;

  PraiseCard(this.praise, {Key key}) : super(key: key);

  final TextStyle subtitleStyle =
      TextStyle(color: Colors.grey, fontSize: Constants.suSetSp(15.0));
  final TextStyle rootTopicTextStyle =
      TextStyle(fontSize: Constants.suSetSp(15.0));
  final TextStyle rootTopicMentionStyle =
      TextStyle(color: Colors.blue, fontSize: Constants.suSetSp(15.0));
  final Color subIconColor = Colors.grey;

  Widget getPraiseAvatar(context, praise) => SizedBox(
        width: Constants.suSetSp(48.0),
        height: Constants.suSetSp(48.0),
        child: GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Constants.suSetSp(24.0)),
            child: FadeInImage(
              fadeInDuration: const Duration(milliseconds: 100),
              placeholder: AssetImage("assets/avatar_placeholder.png"),
              image: UserAPI.getAvatarProvider(uid: praise.uid),
            ),
          ),
          onTap: () => UserPage.jump(context, praise.uid),
        ),
      );

  Text getPraiseNickname(context, praise) => Text(
        praise.nickname ?? praise.uid,
        style: TextStyle(
          color: Theme.of(context).textTheme.title.color,
          fontSize: Constants.suSetSp(19.0),
        ),
        textAlign: TextAlign.left,
      );

  Row getPraiseInfo(praise) {
    String _praiseTime = praise.praiseTime;
    DateTime now = DateTime.now();
    if (int.parse(_praiseTime.substring(0, 4)) == now.year) {
      _praiseTime = _praiseTime.substring(5, 16);
    }
    if (int.parse(_praiseTime.substring(0, 2)) == now.month &&
        int.parse(_praiseTime.substring(3, 5)) == now.day) {
      _praiseTime = "${_praiseTime.substring(5, 11)}";
    }
    return Row(
      children: <Widget>[
        Icon(
          Icons.access_time,
          color: Colors.grey,
          size: Constants.suSetSp(13.0),
        ),
        Text(" $_praiseTime", style: subtitleStyle),
      ],
    );
  }

  Widget getPraiseContent(context, praise) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: Constants.suSetSp(8.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0)),
                  child: Text("赞了这条微博",
                      style: TextStyle(fontSize: Constants.suSetSp(18.0))),
                ),
                getRootContent(context, praise)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getRootContent(context, praise) {
    Post _post = Post.fromJson(praise.post);
    String topic = "<M ${_post.uid}>@${_post.nickname}<\/M>: ";
    topic += _post.content;
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
      padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(16.0),
          vertical: Constants.suSetSp(10.0)),
      decoration: BoxDecoration(color: Theme.of(context).canvasColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getExtendedText(context, topic),
        ],
      ),
    );
  }

  Widget getExtendedText(context, content) {
    return ExtendedText(
      content != null ? "$content " : null,
      style: TextStyle(fontSize: Constants.suSetSp(18.0)),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          SearchPage.search(context, text.substring(1, text.length - 1));
        } else if (text.startsWith("@")) {
          UserPage.jump(context, data['uid']);
        } else if (text.startsWith(API.wbHost)) {
          CommonWebPage.jump(context, text, "网页链接");
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      overflow: TextOverflow.ellipsis,
      maxLines: 7,
    );
  }

  @override
  Widget build(BuildContext context) {
    Post _post = Post.fromJson(this.praise.post);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PostDetailPage(_post, parentContext: context);
        }));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: Constants.suSetSp(8.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(16.0),
                vertical: Constants.suSetSp(12.0),
              ),
              child: Row(
                children: <Widget>[
                  getPraiseAvatar(context, this.praise),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getPraiseNickname(context, this.praise),
                          Constants.separator(context, height: 4.0),
                          getPraiseInfo(this.praise),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            getPraiseContent(context, this.praise),
          ],
        ),
        elevation: 0,
      ),
    );
  }
}
