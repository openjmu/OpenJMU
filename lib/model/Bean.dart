import 'dart:math' as math;

import 'package:flutter/material.dart' show ScaffoldPrelayoutGeometry, FloatingActionButtonLocation;
import 'package:flutter/widgets.dart';

/// 动态实体
/// [id] 动态id, [uid] 用户uid, [nickname] 用户名称, [avatar] 用户头像, [postTime] 动态时间, [from] 动态来源
/// [glances] 被查看次数, [category] 动态类型, [content] 动态内容, [pics] 动态图片
/// [forwards] 转发次数, [comments] 评论次数, [praises] 点赞次数, [isLike] 当前用户是否已赞, [rootTopic] 原动态
///
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
    bool operator == (Object other) => identical(this, other) || other is Post && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    Post copy() {
        return Post(id,uid, nickname, avatar, postTime, from, glances, category, content, pics.sublist(0), forwards, comments, praises, rootTopic, isLike: isLike);
    }
}

///
/// 评论实体
/// [id] 评论id, [fromUserUid] 评论uid, [fromUserName] 评论用户名, [fromUserAvatar] 评论用户头像
/// [content] 评论内容, [commentTime] 评论时间, [from] 来源
///
class Comment {
    int id, fromUserUid;
    String fromUserName;
    String fromUserAvatar;
    String content;
    String commentTime;
    String from;

    bool toReplyExist, toTopicExist;
    int toReplyUid, toTopicUid;
    String toReplyUserName, toTopicUserName;
    var toReplyContent, toTopicContent;

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
            this.post);

    @override
    bool operator == (Object other) => identical(this, other) || other is Comment && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

///
/// 点赞实体
/// [id] 点赞id， [uid] 用户uid, [postId] 被赞动态id, [avatar] 用户头像, [praiseTime] 点赞时间, [nickname] 用户昵称
/// [post] 被赞动态数据, [topicUid] 动态用户uid, [topicNickname] 动态用户名称, [pics] 动态图片
///
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
            this.pics);

    @override
    bool operator == (Object other) => identical(this, other) || other is Comment && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

///
/// 用户页用户实体
/// [id] 用户id, [nickname] 名称, [gender] 性别, [topics] 动态数, [latestTid] 最新动态id
/// [fans] 粉丝数, [idols] 关注数, [isFollowing] 是否已关注
///
class User {
    int id;
    String nickname;
    int gender;
    int topics;
    int latestTid;
    int fans, idols;
    bool isFollowing;

    User(this.id, this.nickname, this.gender, this.topics, this.latestTid, this.fans, this.idols, this.isFollowing);

    @override
    bool operator == (Object other) => identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

///
/// 用户信息实体
/// [sid] 用户token, [ticket] 用户当前token, [blowfish] 用户设备uuid
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id, [name] 名称, [signature] 签名, [isFollowing] 是否已关注
///
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

    UserInfo(
            this.sid,
            this.uid,
            this.name,
            this.signature,
            this.ticket,
            this.blowfish,
            this.unitId,
            this.workId,
            this.classId,
            this.isFollowing,
            );

    @override
    bool operator == (Object other) => identical(this, other) || other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

    @override
    int get hashCode => uid.hashCode;
}

///
/// 用户个性标签
/// [id] 标签id, [name] 名称
///
class UserTag {
    int id;
    String name;

    UserTag(this.id, this.name);

    @override
    bool operator ==(Object other) => identical(this, other) || other is UserTag && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

///
/// 应用中心应用
/// [id] 应用id, [sequence] 排序下标, [code] 代码, [name] 名称, [url] 地址, [menuType] 分类
///
class WebApp {
    int id;
    int sequence;
    String code;
    String name;
    String url;
    String menuType;

    WebApp(this.id, this.sequence, this.code, this.name, this.url, this.menuType);

    @override
    bool operator ==(Object other) => identical(this, other) || other is WebApp && runtimeType == other.runtimeType && id == other.id;

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

///
/// Inherit from default centerDockedLocation.
///
abstract class CustomDockedPosition extends FloatingActionButtonLocation {
    const CustomDockedPosition();

    @protected
    double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
        final double contentBottom = scaffoldGeometry.contentBottom;
        final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
        final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
        final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

        double fabY = contentBottom - fabHeight / 2.0;
        if (snackBarHeight > 0.0)
            fabY = math.min(fabY, contentBottom - snackBarHeight - fabHeight - 16.0);
        if (bottomSheetHeight > 0.0)
            fabY = math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);

        final double maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;
        return math.min(maxFabY, fabY);
    }
}

class CustomEndDockedFloatingActionButtonLocation extends CustomDockedPosition {
    const CustomEndDockedFloatingActionButtonLocation();

    @override
    Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
        final double fabX = _endOffset(scaffoldGeometry);
        return Offset(fabX, getDockedY(scaffoldGeometry) + 10.0);
    }

    @override
    String toString() => 'FloatingActionButtonLocation.endDocked';
}

class CustomCenterDockedFloatingActionButtonLocation extends CustomDockedPosition {
    const CustomCenterDockedFloatingActionButtonLocation();

    @override
    Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
        final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
        return Offset(fabX, getDockedY(scaffoldGeometry) - 10.0);
    }

    @override
    String toString() => 'FloatingActionButtonLocation.customCenterDocked';
}

double _leftOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, { double offset = 0.0 }) {
    return 16 + scaffoldGeometry.minInsets.left - offset;
}

double _rightOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, { double offset = 0.0 }) {
    return scaffoldGeometry.scaffoldSize.width
            - 16
            - scaffoldGeometry.minInsets.right
            - scaffoldGeometry.floatingActionButtonSize.width
            + offset;
}

double _endOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, { double offset = 0.0 }) {
    assert(scaffoldGeometry.textDirection != null);
    switch (scaffoldGeometry.textDirection) {
        case TextDirection.rtl:
            return _leftOffset(scaffoldGeometry, offset: offset);
        case TextDirection.ltr:
            return _rightOffset(scaffoldGeometry, offset: offset);
    }
    return null;
}