///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-22 14:53
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

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
    if (post.praisor != null) {
      post.praisor.add(<String, dynamic>{
        'uid': UserAPI.currentUser.uid,
        'nickname': UserAPI.currentUser.name,
        'sysavatar': 0,
      });
    }
    notifyListeners();
  }

  void unPraised() {
    post.praisesCount--;
    post.isLike = false;
    if (post.praisor != null) {
      post.praisor.removeWhere(
        (Map user) => user['uid'] == UserAPI.currentUser.uid,
      );
    }
    notifyListeners();
  }
}
