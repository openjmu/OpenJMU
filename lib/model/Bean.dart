import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart' show ScaffoldPrelayoutGeometry, FloatingActionButtonLocation;
import 'package:flutter/widgets.dart';

import 'package:OpenJMU/constants/Constants.dart';


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

    Post({
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
        this.isLike = false,
    });

    @override
    bool operator == (Object other) => identical(this, other) || other is Post && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    @override
    String toString() {
        return "Post ${JsonEncoder.withIndent("  ").convert({
            "id": id,
            "uid": uid,
            "nickname": nickname,
            "avatar": avatar,
            "postTime": postTime,
            "from": from,
            "glances": glances,
            "category": category,
            "content": content,
            "pics": pics,
            "forwards": forwards,
            "comments": comments,
            "praises": praises,
            "rootTopic": rootTopic,
            "isLike": isLike,
        })}";
    }

    Post copy() {
        return Post(
            id: id,
            uid: uid,
            nickname: nickname,
            avatar: avatar,
            postTime: postTime,
            from: from,
            glances: glances,
            category: category,
            content: content,
            pics: pics.sublist(0),
            forwards: forwards,
            comments: comments,
            praises: praises,
            rootTopic: rootTopic,
            isLike: isLike,
        );
    }
}

///
/// 动态枚举类型
/// [square] 来自广场的动态, [team] 来自小组的动态
///
enum PostType {
    square,
    team,
}

///
/// 评论实体
/// [id] 评论id, [fromUserUid] 评论uid, [fromUserName] 评论用户名, [fromUserAvatar] 评论用户头像
/// [content] 评论内容, [commentTime] 评论时间, [from] 来源
///
class Comment {
    int id, fromUserUid, floor;
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

    Comment({
        this.id,
        this.floor,
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
    });

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

    Praise({
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
    });

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

    User({
        this.id,
        this.nickname,
        this.gender,
        this.topics,
        this.latestTid,
        this.fans,
        this.idols,
        this.isFollowing,
    });

    @override
    bool operator == (Object other) => identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    @override
    String toString() {
        return 'User ${JsonEncoder.withIndent("  ").convert({
            "id": id,
            "nickname": nickname,
            "gender": gender,
            "topics": topics,
            "latestTid": latestTid,
            "fans": fans,
            "idols": idols,
            "isFollowing": isFollowing,
        })}';
    }

}

///
/// 用户信息实体
/// [sid] 用户token, [ticket] 用户当前token, [blowfish] 用户设备uuid
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
///
class UserInfo {
    /// For Login Process
    String sid;
    String ticket;
    String blowfish;
    bool isTeacher;
    bool isCY;

    /// Common Object
    int uid;
    int unitId;
    int classId;
    int gender;
    String name;
    String signature;
    String workId;
    bool isFollowing;

    UserInfo({
        this.sid,
        this.uid,
        this.name,
        this.signature,
        this.ticket,
        this.blowfish,
        this.isTeacher,
        this.isCY,
        this.unitId,
        this.workId,
        this.classId,
        this.gender,
        this.isFollowing,
    });

    @override
    bool operator == (Object other) => identical(this, other) || other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

    @override
    int get hashCode => uid.hashCode;

    @override
    String toString() {
        return "UserInfo ${JsonEncoder.withIndent("  ").convert({
            'sid': sid,
            'uid': uid,
            'name': name,
            'signature': signature,
            'ticket': ticket,
            'blowfish': blowfish,
            'isTeacher': isTeacher,
            'isCY': isCY,
            'unitId': unitId,
            'workId': workId,
//            'classId': classId,
            'gender': gender,
            'isFollowing': isFollowing,
        })}";
    }

    factory UserInfo.fromJson(Map<String, dynamic> json) {
        json.forEach((k, v) {
            if (json[k] == "") json[k] = null;
        });
        return UserInfo(
            sid: json['sid'],
            uid: json['uid'],
            name: json['username'] ?? json['uid'].toString(),
            signature: json['signature'],
            ticket: json['sid'],
            blowfish: json['blowfish'],
            isTeacher: json['isTeacher'] ?? int.parse(json['type'].toString()) == 1,
            isCY: json['isCY'],
            unitId: json['unitId'] ?? json['unitid'],
            workId: (json['workId'] ?? json['workid'] ?? json['uid']).toString(),
            classId: null,
            gender: int.parse(json['gender'].toString()),
            isFollowing: false,
        );
    }
}

///
/// 用户个性标签
/// [id] 标签id, [name] 名称
///
class UserTag {
    int id;
    String name;

    UserTag({this.id, this.name});

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

    WebApp({this.id, this.sequence, this.code, this.name, this.url, this.menuType});

    factory WebApp.fromJson(Map<String, dynamic> json) {
        return WebApp(
            id: json['appid'],
            sequence: json['sequence'],
            code: json['code'],
            name: json['name'],
            url: json['url'],
            menuType: json['menutype'],
        );
    }

    @override
    bool operator ==(Object other) => identical(this, other) || other is WebApp && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    static Map category = {
//        "10": "个人事务",
        "A4": "我的服务",
        "A3": "我的系统",
        "A8": "流程服务",
        "A2": "我的媒体",
        "A1": "我的网站",
        "A5": "其他",
        "20": "行政办公",
        "30": "客户关系",
        "40": "知识管理",
        "50": "交流中心",
        "60": "人力资源",
        "70": "项目管理",
        "80": "档案管理",
        "90": "教育在线",
        "A0": "办公工具",
        "Z0": "系统设置",
    };
}

class News {
    int id;
    String title;
    String summary;
    String postTime;
    int cover;
    int relateTopicId;
    int heat;
    int praises;
    int replies;
    int glances;
    bool isLiked;

    News({
        this.id,
        this.title,
        this.summary,
        this.postTime,
        this.cover,
        this.relateTopicId,
        this.heat,
        this.praises,
        this.replies,
        this.glances,
        this.isLiked,
    });

    @override
    bool operator ==(Object other) =>
            identical(this, other)
            ||
                    other is WebApp
                    &&
                            runtimeType == other.runtimeType
                            &&
                            id == other.id
    ;

    @override
    int get hashCode => id.hashCode;
}

///
/// 通知类
/// [count] 通知计数, [at] @人计数, [comment] 评论, [praise] 点赞
///
class Notifications {
    int count, at, comment, praise;

    Notifications({this.count = 0, this.at = 0, this.comment = 0, this.praise = 0});
}

///
/// 课程
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称, [teacher] 教师名称,
/// [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [classesName] 共同上课的班级,
/// [isEleven] 是否第十一节,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周
///
class Course {
    String name, time, location, className, teacher;
    int day, startWeek, endWeek, oddEven;
    List<String> classesName;
    bool isEleven;

    Course({
        this.name,
        this.time,
        this.location,
        this.className,
        this.teacher,
        this.day,
        this.startWeek,
        this.endWeek,
        this.classesName,
        this.isEleven,
        this.oddEven,
    });

    String get uniqueId => "$name\$$time\$$day\$$startWeek\$$endWeek";

    static int judgeOddEven(Map<String, dynamic> json) {
        int _oddEven = 0;
        List _split = json['allWeek'].split(' ');
        if (_split.length > 1) {
            if (_split[1] == "单周") {
                _oddEven = 1;
            } else if (_split[1] == "双周") {
                _oddEven = 2;
            }
        }
        return _oddEven;
    }

    factory Course.fromJson(Map<String, dynamic> json) {
        final int _oddEven = judgeOddEven(json);
        final List weeks = json['allWeek'].split(' ')[0].split('-');
        return Course(
            name: json['couName'],
            time: json['coudeTime'],
            location: json['couRoom'],
            className: json['className'],
            teacher: json['couTeaName'],
            day: json['couDayTime'],
            startWeek: int.parse(weeks[0]),
            endWeek: int.parse(weeks[1]),
            classesName: json['comboClassName'].split(','),
            isEleven: json['three'] == 'y',
            oddEven: _oddEven,
        );
    }

    @override
    String toString() {
        return "Course ${JsonEncoder.withIndent("  ").convert({
            'name': name,
            'time': time,
            'room': location,
            'className': className,
            'teacher': teacher,
            'day': day,
            'startWeek': startWeek,
            'endWeek': endWeek,
            'classesName': classesName,
            'isEleven': isEleven,
            'oddEven': oddEven,
        })}";
    }

}

///
/// 成绩类
/// [code] 课程代码, [courseName] 课程名称, [score] 成绩, [termId] 学年学期, [credit] 学分, [creditHour] 学时
///
class Score {
    String code, courseName, score, termId;
    double credit, creditHour;

    Score({this.code, this.courseName, this.score, this.termId, this.credit, this.creditHour});

    factory Score.fromJson(Map<String, dynamic> json) {
        return Score(
            code: json['code'],
            courseName: json['courseName'],
            score: json['score'],
            termId: json['termId'],
            credit: double.parse(json['credit']),
            creditHour: double.parse(json['creditHour']),
        );
    }

    @override
    String toString() {
        return "Score ${JsonEncoder.withIndent("  ").convert({
            'code': code,
            'courseName': courseName,
            'termId': termId,
            'score': score,
            'credit': credit,
            'creditHour': creditHour,
        })}";
    }
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
    final double offsetY;
    const CustomEndDockedFloatingActionButtonLocation(this.offsetY);

    @override
    Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
        final double fabX = _endOffset(scaffoldGeometry);
        return Offset(fabX, getDockedY(scaffoldGeometry) + Constants.suSetSp(this.offsetY));
    }
}

class CustomCenterDockedFloatingActionButtonLocation extends CustomDockedPosition {
    final double offsetY;
    const CustomCenterDockedFloatingActionButtonLocation(this.offsetY);

    @override
    Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
        final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
        return Offset(fabX, getDockedY(scaffoldGeometry) + Constants.suSetSp(this.offsetY));
    }
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

class NoGlowScrollBehavior extends ScrollBehavior {
    @override
    Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
        return child;
    }
}