class Post {
  int id;
  int userId;
  String nickname;
  String avatar;
  String postTime;
  String from;
  int glances;
  String category;
  String content;
  List pics;
  int forwards;
  int replys;
  int praises;
  bool isLike;
  Object rootTopic;

  Post(
      this.id,
      this.userId,
      this.nickname,
      this.avatar,
      this.postTime,
      this.from,
      this.glances,
      this.category,
      this.content,
      this.pics,
      this.forwards,
      this.replys,
      this.praises,
      this.rootTopic,
      {this.isLike = false}
  );

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Post copy() {
    return Post(
        id,
        userId,
        nickname,
        avatar,
        postTime,
        from,
        glances,
        category,
        content,
        pics.sublist(0),
        forwards,
        replys,
        praises,
        rootTopic,
        isLike: isLike
    );
  }
}

class PostComment {
  int id;
  int userId;
  PostComment theComment;
  List<PostComment> children;
  int childCount;
  int time;
  String userNickname;
  String userAvatar;
  String content;

  String fatherNickname;
  String fatherAvatar;
  int fatherId;


  PostComment({this.id, this.userId, this.theComment, this.children, this.childCount, this.time, this.userNickname, this.userAvatar, this.content, this.fatherNickname, this.fatherAvatar, this.fatherId});

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is PostComment &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class User {
  int id;
  String nickname;
  int gender;
  String studentNumber;
  String name;
  String avatar;
  String signature;
  String passwd;
  String major;
  String depart;
  bool bindCard;
  int verification;
  String token;
  int fansCount;
  int followingCount;
  bool followed;

  User.name({
    this.id,
    this.nickname,
    this.gender,
    this.studentNumber,
    this.name,
    this.avatar,
    this.signature,
    this.passwd,
    this.major,
    this.depart,
    this.bindCard,
    this.verification,
    this.token,
    this.fansCount = 0,
    this.followingCount = 0,
    this.followed = false
  });

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

  UserInfo(
      this.sid,
      this.uid,
      this.name,
      this.signature,
      this.ticket,
      this.blowfish,
      this.unitId,
      this.workId,
      this.classId
  );

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is UserInfo &&
              runtimeType == other.runtimeType &&
              uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

}

class WebApp {
  int id;
  int sequence;
  String code;
  String name;
  String url;
  String menuType;

  WebApp(
      this.id,
      this.sequence,
      this.code,
      this.name,
      this.url,
      this.menuType
  );

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