import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class PraiseCard extends StatefulWidget {
  final Praise praise;

  PraiseCard(this.praise, {Key key}) : super(key: key);

  @override
  State createState() => _PraiseCardState();
}

class _PraiseCardState extends State<PraiseCard> {
  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = new TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

  Color currentRootContentColor = Colors.grey[200];

  Widget pics;

  @override
  void initState() {
    super.initState();
    DataUtils.getBrightnessDark().then((isDark) {
      if (this.mounted) {
        setRootContentColor(isDark);
      }
    });
  }

  void setRootContentColor(isDarkState) {
    setState(() {
      if (isDarkState == null || !isDarkState) {
        currentRootContentColor = Colors.grey[200];
      } else {
        currentRootContentColor = Colors.grey[850];
      }
    });
  }

  GestureDetector getCommentAvatar(context, praise) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(praise.avatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, praise.uid);
        }
    );
  }

  Text getCommentNickname(praise) {
    return new Text(
      praise.nickname ?? praise.uid,
      style: titleTextStyle,
      textAlign: TextAlign.left,
    );
  }

  Row getCommentInfo(praise) {
    String _praiseTime = praise.praiseTime;
    DateTime now = new DateTime.now();
    if (int.parse(_praiseTime.substring(0, 4)) == now.year) {
      _praiseTime = _praiseTime.substring(5, 16);
    }
    if (
    int.parse(_praiseTime.substring(0, 2)) == now.month
        &&
        int.parse(_praiseTime.substring(3, 5)) == now.day
    ) {
      _praiseTime = "${_praiseTime.substring(5, 11)}";
    }
    return new Row(
        children: <Widget>[
          new Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $_praiseTime",
              style: subtitleStyle
          ),
        ]
    );
  }

  Widget getCommentContent(context, praise) {
    return new Row(
        children: <Widget>[
          new Expanded(
              child: new Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("赞了这条微博"),
                        getRootContent(context, praise)
                      ]
                  )
              )
          )
        ]
    );
  }

  Widget getRootContent(context, praise) {
    Post _post = PostAPI.createPost(praise.post);
    String topic = "<M ${_post.userId}>@${_post.nickname}<\/M>: ";
    topic += _post.content;
    return new Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: new BoxDecoration(
            color: currentRootContentColor,
            borderRadius: BorderRadius.circular(5.0)
        ),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getExtendedText(topic),
            ]
        )
    );
  }

  Widget getExtendedText(content) {
    return new ExtendedText(
      content,
      style: new TextStyle(fontSize: 16.0),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          return SearchPage.search(context, text.substring(1, text.length-1));
        } else if (text.startsWith("@")) {
          return UserPage.jump(context, data['uid']);
        } else if (text.startsWith("https://wb.jmu.edu.cn")) {
          return CommonWebPage.jump(context, text, "网页链接");
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        overflow: ExtendedTextOverflow.ellipsis,
        maxLines: 7,
    );
  }

  Widget getImages(data) {
    if (data != null) {
      List<Widget> imagesWidget = [];
      for (var index = 0; index < data.length; index++) {
        String imageUrl = data[index]['image_original'];
        String urlInsecure = imageUrl.replaceAllMapped(new RegExp(r"https://"), (match) => "http://");
        imagesWidget.add(
            new GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ImageViewer(
                      index,
                      data.map<ImageBean>((f) {
                        String _httpsUrl = f['image_original'];
                        String url = _httpsUrl.replaceAllMapped(new RegExp(r"https://"), (match) => "http://");
                        return ImageBean(url, widget.praise.postId);
                      }).toList(),
                    );
                  }));
                },
                child: new Hero(
                    tag: "$urlInsecure${index.toString()}${widget.praise.postId.toString()}",
                    child: ExtendedImage.network(
                      urlInsecure,
                      fit: BoxFit.cover,
                      cache: true,
                    )
//                    child: new Image(image: CachedNetworkImageProvider(urlInsecure, cacheManager: DefaultCacheManager()), fit: BoxFit.cover)
                )
            )
        );
      }
      int itemCount = 3;
      if (data.length == 1) {
        return new Container(
            padding: EdgeInsets.only(top: 8.0),
            child: imagesWidget[0]
        );
      } else if (data.length < 3) {
        itemCount = data.length;
      }
      return new Container(
          child: new GridView.count(
              padding: EdgeInsets.only(top: 8.0),
              shrinkWrap: true,
              primary: false,
              mainAxisSpacing: 8.0,
              crossAxisCount: itemCount,
              crossAxisSpacing: 8.0,
              children: imagesWidget
          )
      );
    } else {
      return new Container();
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [];
    _widgets = [
      new ListTile(
        leading: getCommentAvatar(context, widget.praise),
        title: getCommentNickname(widget.praise),
        subtitle: getCommentInfo(widget.praise),
      ),
      getCommentContent(context, widget.praise),
    ];
    Post _post = PostAPI.createPost(widget.praise.post);
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).push(platformPageRoute(builder: (context) {
          return PostDetailPage(_post);
        }));
      },
      child: Container(
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _widgets,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),
      )
    );
  }

}


class PraiseCardInPost extends StatefulWidget {
  final List<Praise> praises;

  PraiseCardInPost(this.praises, {Key key}) : super(key: key);

  @override
  State createState() => _PraiseCardInPostState();
}

class _PraiseCardInPostState extends State<PraiseCardInPost> {

  GestureDetector getPostAvatar(context, praise) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(praise.avatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, praise.uid);
        }
    );
  }

  Text getPostNickname(praise) {
    return new Text(
        praise.nickname,
        style: TextStyle(
            color: Theme.of(context).textTheme.body1.color,
            fontSize: 18.0
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: ThemeUtils.currentCardColor,
        padding: EdgeInsets.zero,
        child: widget.praises.length > 0
            ? ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            ),
            itemCount: widget.praises.length,
            itemBuilder: (context, index) => Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                getPostAvatar(context, widget.praises[index]),
                Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getPostNickname(widget.praises[index]),
                      ],
                    )
                )
              ],
            )
        )
            : Container(
            height: 120.0,
            child: Center(
                child: Text(
                    "暂无内容",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0
                    )
                )
            )
        )
    );
  }

}
