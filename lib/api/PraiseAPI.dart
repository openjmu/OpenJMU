import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class PraiseAPI {
    static getPraiseList(bool isMore, int lastValue) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${Api.praiseList}/id_max/$lastValue"
                : "${Api.praiseList}"
        ,
    );

    static getPraiseInPostList(postId, {bool isMore, int lastValue}) => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
                ? "${Api.postPraisesList}$postId/id_max/$lastValue"
                : "${Api.postPraisesList}$postId"
        ,
    );

    static Future requestPraise(id, isPraise) async {
        if (isPraise) {
            return NetUtils.postWithCookieAndHeaderSet(
                "${Api.postRequestPraise}$id",
            ).catchError((e) {
                print(e.response);
            });
        } else {
            return NetUtils.deleteWithCookieAndHeaderSet(
                "${Api.postRequestPraise}$id",
            ).catchError((e) {
                print(e.response);
            });
        }
    }

    static Praise createPraiseInPost(itemData) {
        String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
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
