
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

class UserInfo {

  String uapAccount;

  /// For Login Process
  String sid;
  String ticket;
  String blowfish;

  /// Common Object
  num uid;
  num unitId;
  num workId;
  num classId;
  String name;

  UserInfo({this.sid, this.uid, this.name, this.ticket, this.blowfish, this.unitId, this.workId, this.classId, this.uapAccount});

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is PostComment &&
              runtimeType == other.runtimeType &&
              uid == other.id;

  @override
  int get hashCode => uid.hashCode;

}