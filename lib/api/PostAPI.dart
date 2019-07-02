import 'dart:core';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class PostAPI {
    static getPostList(String postType, bool isFollowed, bool isMore, int lastValue, {additionAttrs}) async {
        String _postUrl;
        switch (postType) {
            case "square":
                if (isMore) {
                    if (!isFollowed) {
                        _postUrl = Api.postList + "/id_max/$lastValue";
                    } else {
                        _postUrl = Api.postFollowedList + "/id_max/$lastValue";
                    }
                } else {
                    if (!isFollowed) {
                        _postUrl = Api.postList;
                    } else {
                        _postUrl = Api.postFollowedList;
                    }
                }
                break;
            case "user":
                if (isMore) {
                    _postUrl = "${Api.postListByUid}${additionAttrs['uid']}/id_max/$lastValue";
                } else {
                    _postUrl = "${Api.postListByUid}${additionAttrs['uid']}";
                }
                break;
            case "search":
                if (isMore) {
                    _postUrl = "${Api.postListByWords}${additionAttrs['words']}/id_max/$lastValue";
                } else {
                    _postUrl = "${Api.postListByWords}${additionAttrs['words']}";
                }
                break;
            case "mention":
                if (isMore) {
                    _postUrl = "${Api.postListByMention}/id_max/$lastValue";
                } else {
                    _postUrl = "${Api.postListByMention}";
                }
                break;
        }
        return NetUtils.getWithCookieAndHeaderSet(_postUrl);
    }

    static getForwardListInPost(int postId, {bool isMore, int lastValue}) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${Api.postForwardsList}$postId/id_max/$lastValue"
                : "${Api.postForwardsList}$postId"
        ,
    );

    static glancePost(int postId) {
        return NetUtils.postWithCookieAndHeaderSet(
            Api.postGlance,
            data: {"tids": [postId]},
        ).catchError((e) {
            print(e.toString());
            print(e.response);
        });
    }
    static deletePost(int postId) => NetUtils.deleteWithCookieAndHeaderSet(
        "${Api.postContent}/tid/$postId",
    );

    static postForward(String content, int postId, bool replyAtTheMeanTime) async {
        Map<String, dynamic> data = {
            "content": Uri.encodeFull(content),
            "root_tid": postId,
            "relay": replyAtTheMeanTime ? 3 : 0
        };
        return NetUtils.postWithCookieAndHeaderSet(
            "${Api.postRequestForward}",
            data: data,
        );
    }


    static Post createPost(postData) {
        Map<String, dynamic> _user = postData['user'];
        String _avatar = "${Api.userAvatarInSecure}?uid=${_user['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _postTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(postData['post_time']) * 1000,
        ).toString().substring(0,16);
        Post _post = Post(
            int.parse(postData['tid'].toString()),
            int.parse(postData['uid'].toString()),
            _user['nickname'],
            _avatar,
            _postTime,
            postData['from_string'],
            int.parse(postData['glances'].toString()),
            postData['category'],
            postData['article'] ?? postData['content'],
            postData['image'],
            int.parse(postData['forwards'].toString()),
            int.parse(postData['replys'].toString()),
            int.parse(postData['praises']),
            postData['root_topic'],
            isLike: int.parse(postData['praised'].toString()) == 1,
        );
        return _post;
    }

}
