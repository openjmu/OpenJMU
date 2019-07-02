import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class TeamPostAPI {
    static Future getPostList({bool isMore, int lastTimeStamp, additionAttrs}) async {
        String _postUrl;
        if (isMore) {
            _postUrl = Api.teamPosts(teamId: Constants.fleaMarketTeamId, maxTimeStamp: lastTimeStamp);
        } else {
            _postUrl = Api.teamPosts(teamId: Constants.fleaMarketTeamId);
        }
        return NetUtils.getWithCookieAndHeaderSet(
            _postUrl,
            headers: Constants.header,
        );
    }

    static Post createPost(postData) {
        var _user = postData['user_info'];
        String _avatar = "${Api.userAvatarInSecure}?uid=${_user['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _postTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(postData['post_time']),
        ).toString().substring(0,16);
        Post _post = Post(
            int.parse(postData['tid'].toString()),
            int.parse(_user['uid'].toString()),
            _user['nickname'],
            _avatar,
            _postTime,
            null,
            int.parse(postData['glances'].toString()),
            postData['category'],
            postData['article'] ?? postData['content'],
            postData['file_info'],
            null,
            int.parse(postData['replys'].toString()),
            int.parse(postData['praises'].toString()),
            postData['root_topic'],
            isLike: int.parse(postData['praised'].toString()) == 1,
        );
        return _post;
    }

    static Future getPostDetail({int id, int postType}) => NetUtils.getWithCookieAndHeaderSet(
        Api.teamPostDetail(postId: id, postType: postType),
        headers: Constants.header,
    );
}

class TeamCommentAPI {
    static getCommentInPostList({int id, int page}) async => NetUtils.getWithCookieAndHeaderSet(
        "${Api.teamPostCommentsList(postId: id, page: (page ?? 1))}",
        headers: Constants.header,
    );

    static Comment createCommentInPost(itemData) {
        String _avatar = "{Api.userAvatarInSecure}"
                "?uid=${itemData['user_info']['uid']}"
                "&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}"
        ;
        String _commentTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(itemData['post_time']),
        ).toString().substring(0, 16);
        Comment _comment = Comment(
            int.parse(itemData['tid'].toString()),
            int.parse(itemData['floor'].toString()),
            int.parse(itemData['user_info']['uid'].toString()),
            itemData['user_info']['nickname'],
            _avatar,
            itemData['content'],
            _commentTime,
            itemData['from_string'],
            null,
            null,
            null,
            null,
            false,
            0,
            null,
            null,
            itemData['post'],
        );
        return _comment;
    }
}

class TeamPraiseAPI {
    static getPraiseList(bool isMore, int lastValue) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${Api.praiseList}/id_max/$lastValue"
                : "${Api.praiseList}"
        ,
    );

    static Future requestPraise(id, isPraise) async {
        if (isPraise) {
            return NetUtils.postWithCookieAndHeaderSet(
                "${Api.postRequestPraise}$id",
            ).catchError((e) {
                print(e.response["msg"]);
            });
        } else {
            return NetUtils.deleteWithCookieAndHeaderSet(
                "${Api.postRequestPraise}$id",
            ).catchError((e) {
                print(e.response["msg"]);
            });
        }
    }

    static Praise createPraiseInPost(itemData) {
        String _avatar = "${Api.userAvatarInSecure}"
                "?uid=${itemData['user']['uid']}"
                "&size=f152"
                "&_t=${DateTime.now().millisecondsSinceEpoch}"
        ;
        String _praiseTime = DateTime.fromMillisecondsSinceEpoch(
            itemData['praise_time'] * 1000,
        ).toString().substring(0,16);
        Praise _praise = Praise(
            id: itemData['id'],
            uid: itemData['user']['uid'],
            avatar: _avatar,
            postId: null,
            praiseTime: _praiseTime,
            nickname: itemData['user']['nickname'],
            post: null,
            topicUid: null,
            topicNickname: null,
            pics: null,
        );
        return _praise;
    }

    static Praise createPraise(itemData) {
        String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
        String _praiseTime = DateTime.fromMillisecondsSinceEpoch(
            itemData['praise_time'] * 1000,
        ).toString().substring(0,16);
        Praise _praise = Praise(
            id: itemData['id'],
            uid: itemData['user']['uid'],
            avatar: _avatar,
            postId: int.parse(itemData['topic']['tid'].toString()),
            praiseTime: _praiseTime,
            nickname: itemData['user']['nickname'],
            post: itemData['topic'],
            topicUid: int.parse(itemData['topic']['user']['uid'].toString()),
            topicNickname: itemData['topic']['user']['nickname'],
            pics: itemData['topic']['image'],
        );
        return _praise;
    }

}
