class Post {
    int id;
    int uid;
    String nickname;
    String avatar;
    String postTime;
    String from;
    int glances;
    String category;
    String content;
    List pics;
    int forwards;
    int comments;
    int praises;
    bool isLike;
    Object rootTopic;

    Post(
            this.id,
            this.uid,
            this.nickname,
            this.avatar,
            this.postTime,
            this.from,
            this.glances,
            this.category,
            this.content,
            this.pics,
            this.forwards,
            this.comments,
            this.praises,
            this.rootTopic,
            {this.isLike = false});

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is Post && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    Post copy() {
        return Post(id, uid, nickname, avatar, postTime, from, glances, category,
                content, pics.sublist(0), forwards, comments, praises, rootTopic,
                isLike: isLike);
    }
}

class Comment {
    int id, fromUserUid;
    String fromUserName;
    String fromUserAvatar;
    String content;
    String commentTime;
    String from;

    bool toReplyExist;
    int toReplyUid;
    String toReplyUserName;
    var toReplyContent;
    bool toTopicExist;
    int toTopicUid;
    String toTopicUserName;
    var toTopicContent;

    Post post;

    Comment(
            this.id,
            this.fromUserUid,
            this.fromUserName,
            this.fromUserAvatar,
            this.content,
            this.commentTime,
            this.from,
            this.toReplyExist,
            this.toReplyUid,
            this.toReplyUserName,
            this.toReplyContent,
            this.toTopicExist,
            this.toTopicUid,
            this.toTopicUserName,
            this.toTopicContent,
            this.post,
            );

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is Comment && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

class Praise {
    int id, uid, postId;
    String avatar;
    String praiseTime;
    String nickname;
    Map<String, dynamic> post;
    int topicUid;
    String topicNickname;
    List pics;

    Praise(
            this.id,
            this.uid,
            this.avatar,
            this.postId,
            this.praiseTime,
            this.nickname,
            this.post,
            this.topicUid,
            this.topicNickname,
            this.pics,
            );

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is Comment && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

class User {
    int id;
    String nickname;
    int gender;
    int topics;
    int latestTid;
    int fans, idols;
    bool isFollowing;

    User(this.id, this.nickname, this.gender, this.topics, this.latestTid,
            this.fans, this.idols, this.isFollowing);

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is User && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

class UserInfo {
    /// For Login Process
    String sid;
    String ticket;
    String blowfish;

    /// Common Object
    int uid;
    int unitId;
    int workId;
    int classId;
    String name;
    String signature;
    bool isFollowing;

    UserInfo(this.sid, this.uid, this.name, this.signature, this.ticket,
            this.blowfish, this.unitId, this.workId, this.classId, this.isFollowing);

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

    @override
    int get hashCode => uid.hashCode;
}

class UserTag {
    int id;
    String name;

    UserTag(this.id, this.name);

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is UserTag && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

class WebApp {
    int id;
    int sequence;
    String code;
    String name;
    String url;
    String menuType;

    WebApp(this.id, this.sequence, this.code, this.name, this.url, this.menuType);

    @override
    bool operator ==(Object other) =>
            identical(this, other) ||
                    other is WebApp && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    static Map category() {
        return {
            "10": "个人事务",
            "A4": "我的服务",
            "A3": "我的系统",
            "A8": "流程服务",
            "A2": "我的媒体",
            "A5": "其他",
        };
    }
}

class Notifications {
    int count, at, comment, praise;

    Notifications(this.count, this.at, this.comment, this.praise);
}
