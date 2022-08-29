import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';
export 'package:openjmu/controller/comment_controller.dart';
export 'package:openjmu/controller/post_controller.dart';
export 'package:openjmu/controller/praise_controller.dart';
export 'package:openjmu/model/loading_base.dart';
export 'package:openjmu/model/special_text.dart';

part 'models.g.dart';

part 'app_message.dart';

part 'blacklist_user.dart';

part 'changelog.dart';

part 'cloud_settings.dart';

part 'comment.dart';

part 'course.dart';

part 'emoji_model.dart';

part 'image_bean.dart';

part 'json_model.dart';

part 'message.dart';

part 'news.dart';

part 'notifications.dart';

part 'packet.dart';

part 'post.dart';

part 'praise.dart';

part 'score.dart';

part 'team_mention.dart';

part 'team_notifications.dart';

part 'team_post.dart';

part 'team_post_comment.dart';

part 'team_praise.dart';

part 'team_reply.dart';

part 'theme_group.dart';

part 'up_model.dart';

part 'user.dart';

part 'user_info.dart';

part 'user_level.dart';

part 'user_tag.dart';

part 'web_app.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) =>
      child;
}
