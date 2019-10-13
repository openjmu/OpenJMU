import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class PostAPI {
    static getPostList(String postType, bool isFollowed, bool isMore, int lastValue, {additionAttrs}) async {
        String _postUrl;
        switch (postType) {
            case "square":
                if (isMore) {
                    if (!isFollowed) {
                        _postUrl = API.postList + "/id_max/$lastValue";
                    } else {
                        _postUrl = API.postFollowedList + "/id_max/$lastValue";
                    }
                } else {
                    if (!isFollowed) {
                        _postUrl = API.postList;
                    } else {
                        _postUrl = API.postFollowedList;
                    }
                }
                break;
            case "user":
                if (isMore) {
                    _postUrl = "${API.postListByUid}${additionAttrs['uid']}/id_max/$lastValue";
                } else {
                    _postUrl = "${API.postListByUid}${additionAttrs['uid']}";
                }
                break;
            case "search":
                if (isMore) {
                    _postUrl = "${API.postListByWords}${additionAttrs['words']}/id_max/$lastValue";
                } else {
                    _postUrl = "${API.postListByWords}${additionAttrs['words']}";
                }
                break;
            case "mention":
                if (isMore) {
                    _postUrl = "${API.postListByMention}/id_max/$lastValue";
                } else {
                    _postUrl = "${API.postListByMention}";
                }
                break;
        }
        return NetUtils.getWithCookieAndHeaderSet(_postUrl);
    }

    static getForwardListInPost(int postId, {bool isMore, int lastValue}) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${API.postForwardsList}$postId/id_max/$lastValue"
                : "${API.postForwardsList}$postId"
        ,
    );

    static glancePost(int postId) {
        return NetUtils.postWithCookieAndHeaderSet(
            API.postGlance,
            data: {"tids": [postId]},
        ).catchError((e) {
            debugPrint("${e.toString()}");
            debugPrint("${e.response}");
        });
    }
    static deletePost(int postId) => NetUtils.deleteWithCookieAndHeaderSet(
        "${API.postContent}/tid/$postId",
    );

    static postForward(String content, int postId, bool replyAtTheMeanTime) async {
        Map<String, dynamic> data = {
            "content": Uri.encodeFull(content),
            "root_tid": postId,
            "relay": replyAtTheMeanTime ? 3 : 0
        };
        return NetUtils.postWithCookieAndHeaderSet(
            "${API.postRequestForward}",
            data: data,
        );
    }


    static Post createPost(postData) {
        Map<String, dynamic> _user = postData['user'];
        String _avatar = "${API.userAvatarInSecure}?uid=${_user['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _postTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(postData['post_time']) * 1000,
        ).toString().substring(0,16);
        Post _post = Post(
            id: int.parse(postData['tid'].toString()),
            uid: int.parse(postData['uid'].toString()),
            nickname: _user['nickname'],
            avatar: _avatar,
            postTime: _postTime,
            from: postData['from_string'],
            glances: int.parse(postData['glances'].toString()),
            category: postData['category'],
            content: postData['article'] ?? postData['content'],
            pics: postData['image'],
            forwards: int.parse(postData['forwards'].toString()),
            comments: int.parse(postData['replys'].toString()),
            praises: int.parse(postData['praises']),
            rootTopic: postData['root_topic'],
            isLike: int.parse(postData['praised'].toString()) == 1,
        );
        return _post;
    }

}
