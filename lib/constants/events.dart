import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

class ConnectivityChangeEvent {
  const ConnectivityChangeEvent(this.type);

  final ConnectivityResult type;
}

class LogoutEvent {}

class TicketGotEvent {
  const TicketGotEvent([this.isWizard = true]);

  final bool isWizard; // 账号是否已通过新人引导
}

class TicketFailedEvent {}

class PostForwardedEvent {
  const PostForwardedEvent(this.postId, this.forwards);

  final int postId;
  final int forwards;
}

class PostForwardDeletedEvent {
  const PostForwardDeletedEvent(this.postId, this.forwards);

  final int postId;
  final int forwards;
}

class PostCommentedEvent {
  const PostCommentedEvent(this.postId);

  final int postId;
}

class PostCommentDeletedEvent {
  const PostCommentDeletedEvent(this.postId);

  final int postId;
}

class PostPraisedEvent {
  const PostPraisedEvent(this.postId);

  final int postId;
}

class PostUnPraisedEvent {
  const PostUnPraisedEvent(this.postId);

  final int postId;
}

class PostDeletedEvent {
  const PostDeletedEvent(
    this.postId,
    this.page,
    this.index,
  );

  final int postId;
  final String page;
  final int index;
}

class TeamPostDeletedEvent {
  const TeamPostDeletedEvent(this.postId);

  final int postId;
}

class TeamCommentDeletedEvent {
  const TeamCommentDeletedEvent({
    @required this.postId,
    this.topPostId,
  });

  final int postId;
  final int topPostId;
}

class TeamPostCommentDeletedEvent {
  const TeamPostCommentDeletedEvent({
    this.commentId,
    this.topPostId,
  });

  final int commentId;
  final int topPostId;
}

class ForwardInPostUpdatedEvent {
  const ForwardInPostUpdatedEvent(this.postId, this.count);

  final int postId, count;
}

class CommentInPostUpdatedEvent {
  const CommentInPostUpdatedEvent(this.postId, this.count);

  final int postId, count;
}

class PraiseInPostUpdatedEvent {
  const PraiseInPostUpdatedEvent({
    this.postId,
    this.type,
    this.count,
    this.isLike,
  });

  final int postId, count;
  final String type;
  final bool isLike;
}

class FontScaleUpdateEvent {
  const FontScaleUpdateEvent();
}

class HasUpdateEvent {
  const HasUpdateEvent({
    this.forceUpdate,
    this.currentVersion,
    this.currentBuild,
    this.response,
  });

  final bool forceUpdate;
  final String currentVersion;
  final int currentBuild;
  final Map<String, dynamic> response;
}

class BlacklistUpdateEvent {}

class UserFollowEvent {
  const UserFollowEvent({this.isFollow, this.uid});

  final bool isFollow;
  final String uid;
}

class UserAvatarUpdateEvent {}

class ScrollToTopEvent {
  const ScrollToTopEvent({this.tabIndex, this.type});

  final int tabIndex;
  final String type;
}

class PostChangeEvent {
  PostChangeEvent(this.post, [this.remove = false]);

  final Post post;
  final bool remove;
}

class CurrentWeekUpdatedEvent {}

class AppCenterRefreshEvent {
  const AppCenterRefreshEvent(this.currentIndex);

  final int currentIndex;
}

class CourseScheduleRefreshEvent {}

/// Events for message
class MessageReceivedEvent {
  const MessageReceivedEvent({
    this.isSelf = false,
    this.type,
    this.senderUid,
    this.senderMultiPortId,
    this.sendTime,
    this.messageId,
    this.ackId,
    this.content,
  });

  final bool isSelf;
  final int type;
  final String senderUid;
  final String senderMultiPortId;
  final DateTime sendTime;
  final int messageId;
  final int ackId;
  final Map<String, dynamic> content;
}
