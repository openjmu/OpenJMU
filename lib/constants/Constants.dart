import 'package:event_bus/event_bus.dart';

class Constants {
  static final String END_LINE_TAG = "COMPLETE";

  // Fow news list.
  static final String newsApiKey = "c2bd7a89a377595c1da3d49a0ca825d5";

  // For weibo.
  static final String weiboApiKey = "1FD8506EF9FF0FAB7CAFEBB610F536A1";
  static final String weiboApiSecret = "E3277DE3AED6E2E5711A12F707FA2365";

  static EventBus eventBus = new EventBus();
}