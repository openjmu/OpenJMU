import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

class UserInfoGotEvent {
  UserInfo currentUser;
  UserInfoGotEvent(UserInfo userInfo) {
    currentUser = userInfo;
  }
}