import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/api/PostAPI.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class CommentAPI {
    static getCommentList(String commentType, bool isMore, int lastValue, {additionAttrs}) async {
        String _commentUrl;
        switch (commentType) {
            case "reply":
                if (isMore) {
                    _commentUrl = "${Api.commentListByReply}/id_max/$lastValue";
                } else {
                    _commentUrl = "${Api.commentListByReply}";
                }
                break;
            case "mention":
                if (isMore) {
                    _commentUrl = "${Api.commentListByMention}/id_max/$lastValue";
                } else {
                    _commentUrl = "${Api.commentListByMention}";
                }
                break;
        }
        return NetUtils.getWithCookieAndHeaderSet(_commentUrl);
    }
    static getCommentInPostList(int id, {bool isMore, int lastValue}) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${Api.postCommentsList}$id/id_max/$lastValue"
                : "${Api.postCommentsList}$id"
        ,
    );

    static postComment(String content, int postId, bool forwardAtTheMeanTime, {int replyToId}) async {
        Map<String, dynamic> data = {
            "content": Uri.encodeFull(content),
            "reflag": 0,
            "relay": forwardAtTheMeanTime ? 1 : 0,
        };
        String url;
        if (replyToId != null) {
            url = "${Api.postRequestCommentTo}$postId/rid/$replyToId";
            data["without_mention"] = 1;
        } else {
            url = "${Api.postRequestComment}$postId";
        }
        return NetUtils.postWithCookieAndHeaderSet(url, data: data);
    }

    static deleteComment(int postId, int commentId) async => NetUtils.deleteWithCookieAndHeaderSet(
        "${Api.postRequestComment}$postId/rid/$commentId",
    );

    static Comment createComment(itemData) {
        String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _commentTime = DateTime.fromMillisecondsSinceEpoch(
            itemData['post_time'] * 1000,
        ).toString().substring(0,16);
        bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
        bool topicExist = itemData['to_topic']['exists'] == 1 ? true : false;
        Map<String, dynamic> replyData = itemData['to_reply']['reply'];
        Map<String, dynamic> topicData = itemData['to_topic']['topic'];
        Comment _comment = Comment(
            int.parse(itemData['rid'].toString()),
            null,
            int.parse(itemData['user']['uid'].toString()),
            itemData['user']['nickname'],
            _avatar,
            itemData['content'],
            _commentTime,
            itemData['from_string'],
            replyExist,
            replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
            replyExist ? replyData['user']['nickname'] : null,
            replyExist ? replyData['content'] : null,
            topicExist,
            topicExist ? int.parse(topicData['user']['uid'].toString()) : 0,
            topicExist ? topicData['user']['nickname'] : null,
            topicExist
                    ? itemData['to_topic']['topic']['article'] ?? itemData['to_topic']['topic']['content']
                    : null,
            itemData['to_topic']['topic'] != null ? PostAPI.createPost(itemData['to_topic']['topic']) : null,
        );
        return _comment;
    }
    static Comment createCommentInPost(itemData) {
        String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _commentTime = DateTime.fromMillisecondsSinceEpoch(
            itemData['post_time'] * 1000,
        ).toString().substring(0,16);
        bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
        Map<String, dynamic> replyData = itemData['to_reply']['reply'];
        Comment _comment = Comment(
            int.parse(itemData['rid'].toString()),
            null,
            int.parse(itemData['user']['uid'].toString()),
            itemData['user']['nickname'],
            _avatar,
            itemData['content'],
            _commentTime,
            itemData['from_string'],
            replyExist,
            replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
            replyExist ? replyData['user']['nickname'] : null,
            replyExist ? replyData['content'] : null,
            false,
            0,
            null,
            null,
            itemData['post'],
        );
        return _comment;
    }

}
