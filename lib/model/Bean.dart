import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart'
    show ScaffoldPrelayoutGeometry, FloatingActionButtonLocation;
import 'package:flutter/widgets.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/CourseAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';

export 'package:OpenJMU/controller/CommentController.dart';
export 'package:OpenJMU/controller/PostController.dart';
export 'package:OpenJMU/controller/PraiseController.dart';
export 'package:OpenJMU/model/SpecialText.dart';

///
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

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

  factory Post.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    Map<String, dynamic> _user = json['user'];
    _user.forEach((k, v) {
      if (_user[k] == "") _user[k] = null;
    });
    String _avatar =
        "${API.userAvatar}?uid=${_user['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _postTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json['post_time']) * 1000,
    ).toString().substring(0, 16);
    Post _post = Post(
      id: int.parse(json['tid'].toString()),
      uid: int.parse(json['uid'].toString()),
      nickname: _user['nickname'] ?? _user['uid'].toString(),
      avatar: _avatar,
      postTime: _postTime,
      from: json['from_string'],
      glances: int.parse(json['glances'].toString()),
      category: json['category'],
      content: json['article'] ?? json['content'],
      pics: json['image'],
      forwards: int.parse(json['forwards'].toString()),
      comments: int.parse(json['replys'].toString()),
      praises: int.parse(json['praises']),
      rootTopic: json['root_topic'],
      isLike: int.parse(json['praised'].toString()) == 1,
    );
    return _post;
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
/// 小组动态实体
/// [tid] 动态id, [uid] 用户uid, [nickname] 用户名称,
/// [rootTid] 源动态id, [rootUid] 源动态用户id,
/// [postTime] 动态时间, [category] 动态类型,
/// [title] 动态标题, [content] 动态内容, [pics] 动态图片,
/// [postInfo] 动态评论内容, [userInfo] 用户信息, [replyInfo] 回复内容,
/// [repliesCount] 评论次数, [praisesCount] 点赞次数, [glances] 被查看次数,
/// [isLike] 当前用户是否已赞, [praisor] 赞了的人, [heat] 热度, [floor] 楼层,
/// [unitId] 机构id, [groupId] 组别id,
///
class TeamPost {
  int tid, uid, rootTid, rootUid;
  String nickname;
  DateTime postTime;
  String category;
  String title;
  String content;
  List pics;
  List postInfo;
  Map<String, dynamic> userInfo;
  List replyInfo;
  int repliesCount;
  int praisesCount;
  int glances;
  bool isLike;
  List praisor;
  double heat;
  int floor;
  int unitId;
  int groupId;

  TeamPost({
    this.tid,
    this.uid,
    this.rootTid,
    this.rootUid,
    this.nickname,
    this.postTime,
    this.category,
    this.title,
    this.content,
    this.pics,
    this.postInfo,
    this.userInfo,
    this.replyInfo,
    this.repliesCount,
    this.praisesCount,
    this.glances,
    this.isLike = false,
    this.praisor,
    this.heat,
    this.floor,
    this.unitId,
    this.groupId,
  });

  factory TeamPost.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    Map<String, dynamic> _user = json['user_info'];
    _user.forEach((k, v) {
      if (_user[k] == "") _user[k] = null;
    });
    TeamPost _post = TeamPost(
      tid: int.parse(json['tid'].toString()),
      uid: int.parse(_user['uid'].toString()),
      rootTid: int.parse(json['root_tid'].toString()),
      rootUid: int.parse(json['root_uid'].toString()),
      nickname: _user['nickname'] ?? _user['uid'].toString(),
      postTime:
          DateTime.fromMillisecondsSinceEpoch(int.parse(json['post_time'])),
      category: json['category'],
      content: json['content'],
      pics: json['file_info'],
      postInfo: json['post_info'],
      userInfo: _user,
      replyInfo: json['reply_info'],
      repliesCount: int.parse(json['replys'].toString()),
      praisesCount: int.parse(json['praises'].toString()),
      glances: int.parse(json['glances'].toString()),
      isLike: int.parse(json['praised'].toString()) == 1,
      praisor: json['praisor'],
      heat: double.parse(json['heat'].toString()),
      floor: int.parse(json['floor'].toString()),
      unitId: int.parse(json['unit_id'].toString()),
      groupId: int.parse(json['group_id'].toString()),
    );
    return _post;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPost && runtimeType == other.runtimeType && tid == other.tid;

  @override
  int get hashCode => tid.hashCode;

  @override
  String toString() {
    return "TeamPost ${JsonEncoder.withIndent("  ").convert({
      "tid": tid,
      "uid": uid,
      "rootTid": rootTid,
      "rootUid": rootUid,
      "nickname": nickname,
      "postTime": postTime.toString(),
      "category": category,
      "title": title,
      "content": content,
      "pics": pics,
      "postInfo": postInfo,
      "userInfo": userInfo,
      "replyInfo": replyInfo,
      "repliesCount": repliesCount,
      "praisesCount": praisesCount,
      "glances": glances,
      "isLike": isLike,
      "praisor": praisor,
      "heat": heat,
      "floor": floor,
      "unitId": unitId,
      "groupId": groupId,
    })}";
  }
}

///
/// 小组动态评论实体
/// [rid] 评论id, [originId] 原动态id, [uid] 用户uid, [originType] 原动态类型,
/// [postTime] 发布时间, [content] 评论内容, [floor] 楼层,
/// [userInfo] 用户信息,
///
class TeamPostComment {
  int rid, originId, uid;
  String originType;
  DateTime postTime;
  String content;
  int floor;
  Map userInfo;

  TeamPostComment({
    this.rid,
    this.originId,
    this.uid,
    this.originType,
    this.postTime,
    this.content,
    this.floor,
    this.userInfo,
  });

  factory TeamPostComment.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    final _user = json['user'];
    _user.forEach((k, v) {
      if (_user[k] == "") _user[k] = null;
    });
    return TeamPostComment(
      rid: int.parse(json['rid'].toString()),
      originId: int.parse(json['oid'].toString()),
      uid: int.parse(json['uid'].toString()),
      originType: json['otype'],
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ),
      content: json['content'],
      floor: int.parse(json['floor_id'].toString()),
      userInfo: _user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPostComment &&
          runtimeType == other.runtimeType &&
          rid == other.rid;

  @override
  int get hashCode => rid.hashCode;

  @override
  String toString() {
    return 'TeamPostComment ${JsonEncoder.withIndent("  ").convert({
      "rid": rid,
      "originId": originId,
      "uid": uid,
      "originType": originType,
      "postTime": postTime.toString(),
      "content": content,
      "floor": floor,
      "userInfo": userInfo,
    })}';
  }
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
  String toString() {
    return 'Comment{id: $id, fromUserUid: $fromUserUid, floor: $floor, fromUserName: $fromUserName, fromUserAvatar: $fromUserAvatar, content: $content, commentTime: $commentTime, from: $from, toReplyExist: $toReplyExist, toTopicExist: $toTopicExist, toReplyUid: $toReplyUid, toTopicUid: $toTopicUid, toReplyUserName: $toReplyUserName, toTopicUserName: $toTopicUserName, toReplyContent: $toReplyContent, toTopicContent: $toTopicContent, post: $post}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment && runtimeType == other.runtimeType && id == other.id;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment && runtimeType == other.runtimeType && id == other.id;

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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['uid'].toString()),
      nickname: json["nickname"] ??
          json["username"] ??
          json["name"] ??
          json["uid"].toString(),
      gender: json["gender"] ?? 0,
      topics: json["topics"] ?? 0,
      latestTid: json["latest_tid"] ?? null,
      fans: json["fans"] ?? 0,
      idols: json["idols"] ?? 0,
      isFollowing: json["is_following"] == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTag && runtimeType == other.runtimeType && id == other.id;

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

  WebApp({
    this.id,
    this.sequence,
    this.code,
    this.name,
    this.url,
    this.menuType,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'appid': this.id,
      'sequence': this.sequence,
      'code': this.code,
      'name': this.name,
      'url': this.url,
      'menutype': this.menuType,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebApp &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code;

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

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: int.parse(json['post_id'].toString()),
      title: json['title'],
      summary: json['summary'],
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ).toString().substring(0, 16),
      cover: json['cover_img'] != null
          ? int.parse(json['cover_img']['fid'].toString())
          : null,
      relateTopicId:
          json['relate_topic'] != null && json['relate_topic'].isNotEmpty
              ? int.parse(json['relate_topic'][0]['post_id'].toString())
              : null,
      heat: int.parse(json['heat'].toString()),
      praises: int.parse(json['praises'].toString()),
      replies: int.parse(json['replys'].toString()),
      glances: int.parse(json['glances'].toString()),
      isLiked: int.parse(json['praised'].toString()) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebApp && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

///
/// 通知类
/// [count] 通知计数, [at] @人计数, [comment] 评论, [praise] 点赞
///
class Notifications {
  int count, at, comment, praise;

  Notifications({
    this.count = 0,
    this.at = 0,
    this.comment = 0,
    this.praise = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notifications &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

///
/// 课程
/// [isCustom] **必需**是否自定义课程,
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称,
/// [teacher] 教师名称, [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [classesName] 共同上课的班级,
/// [isEleven] 是否第十一节,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周
///
class Course {
  bool isCustom;
  String name, time, location, className, teacher;
  int day, startWeek, endWeek, oddEven;
  List<String> classesName;
  bool isEleven;
  Color color;

  Course({
    @required this.isCustom,
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

  factory Course.fromJson(Map<String, dynamic> json, {bool isCustom = false}) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    final int _oddEven = !isCustom ? judgeOddEven(json) : null;
    final List weeks =
        !isCustom ? json['allWeek'].split(' ')[0].split('-') : null;

    String name;
    if (isCustom) {
      try {
        name = Uri.decodeComponent(json['content']);
      } catch (e) {
        name = json['content'];
      }
    } else {
      name = json['couName'] ?? "(空)";
    }

    Course _c = Course(
      isCustom: isCustom,
      name: name,
      time: !isCustom ? json['coudeTime'] : json['courseTime'].toString(),
      location: json['couRoom'],
      className: json['className'],
      teacher: json['couTeaName'],
      day: !isCustom ? json['couDayTime'] : json['courseDaytime'],
      startWeek: !isCustom ? int.parse(weeks[0]) : null,
      endWeek: !isCustom ? int.parse(weeks[1]) : null,
      classesName: !isCustom ? json['comboClassName'].split(',') : null,
      isEleven: json['three'] == 'y',
      oddEven: _oddEven,
    );
    if (_c.isEleven && _c.time == "90") _c.time = "911";

    final Iterable<Map<String, Color>> courses =
        CourseAPI.coursesColor.where((course) => course.containsKey(_c.name));
    if (courses.isNotEmpty) {
      _c.color = courses.elementAt(0)[_c.name];
    } else {
      uniqueColor(_c, CourseAPI.randomCourseColor());
    }
    return _c;
  }

  static void uniqueColor<bool>(Course course, Color color) {
    Iterable<Map<String, Color>> courses =
        CourseAPI.coursesColor.where((course) => course.containsValue(color));
    if (courses.isNotEmpty) {
      uniqueColor(course, CourseAPI.randomCourseColor());
    } else {
      course.color = color;
      CourseAPI.coursesColor.add({"${course.name}": color});
    }
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

  Score({
    this.code,
    this.courseName,
    this.score,
    this.termId,
    this.credit,
    this.creditHour,
  });

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
/// 消息实体
/// [type] 消息类型 ([Messages.PRPL_91U_MSG_TYPE])
/// [senderUid] 发送方uid
/// [senderMultiPortId] 发送方多点ID
/// [sendTime] 发送时间
/// [ackId] ACK ID
/// [content] 内容
///
class Message {
  int type;
  int senderUid;
  String senderMultiPortId;
  DateTime sendTime;
  String ackId;
  Map<String, dynamic> content;

  Message({
    this.type,
    this.senderUid,
    this.senderMultiPortId,
    this.sendTime,
    this.ackId,
    this.content,
  });

  factory Message.fromEvent(MessageReceivedEvent event) {
    return Message(
      type: event.type,
      senderUid: event.senderUid,
      senderMultiPortId: event.senderMultiPortId,
      sendTime: event.sendTime,
      ackId: event.ackId,
      content: event.content,
    );
  }

  bool get isSelf => this.senderUid == UserAPI.currentUser.uid;
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
      fabY =
          math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);

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
    return Offset(fabX, getDockedY(scaffoldGeometry) + suSetSp(this.offsetY));
  }
}

class CustomCenterDockedFloatingActionButtonLocation
    extends CustomDockedPosition {
  final double offsetY;
  const CustomCenterDockedFloatingActionButtonLocation(this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    return Offset(fabX, getDockedY(scaffoldGeometry) + suSetSp(this.offsetY));
  }
}

double _leftOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  double offset = 0.0,
}) {
  return 16 + scaffoldGeometry.minInsets.left - offset;
}

double _rightOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  double offset = 0.0,
}) {
  return scaffoldGeometry.scaffoldSize.width -
      16 -
      scaffoldGeometry.minInsets.right -
      scaffoldGeometry.floatingActionButtonSize.width +
      offset;
}

double _endOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  double offset = 0.0,
}) {
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
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
