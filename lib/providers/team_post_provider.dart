///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-22 14:53
///
part of 'providers.dart';

class TeamPostProvider extends ChangeNotifier {
  TeamPostProvider(this.post);

  final TeamPost post;

  void replied() {
    post.repliesCount++;
    notifyListeners();
  }

  void commentDeleted() {
    post.repliesCount--;
    notifyListeners();
  }

  void praised() {
    post.praisesCount++;
    post.isLike = true;
    if (post.praisor.isNotEmpty) {
      post.praisor.add(
        PostUser(
          uid: UserAPI.currentUser.uid,
          nickname: UserAPI.currentUser.name ?? UserAPI.currentUser.uid,
          sysAvatar: UserAPI.currentUser.sysAvatar,
        ),
      );
    }
    notifyListeners();
  }

  void unPraised() {
    post.praisesCount--;
    post.isLike = false;
    if (post.praisor.isNotEmpty) {
      post.praisor.removeWhere(
        (PostUser user) => user.uid == UserAPI.currentUser.uid,
      );
    }
    notifyListeners();
  }
}
