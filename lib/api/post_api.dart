import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:openjmu/constants/constants.dart';
import 'package:path/path.dart' as path;

class PostAPI {
  const PostAPI._();

  static Future<Response<Map<String, dynamic>>> getPostList(
    String postType, {
    bool isFollowed = false,
    bool isMore = false,
    int? lastValue,
    Map<String, dynamic>? additionAttrs,
  }) {
    assert(!isMore || lastValue != null);
    late final String _postUrl;
    switch (postType) {
      case 'square':
        if (isMore) {
          if (isFollowed) {
            _postUrl = '${API.postFollowedList}/id_max/$lastValue';
          } else {
            _postUrl = '${API.postList}/id_max/$lastValue';
          }
        } else {
          if (isFollowed) {
            _postUrl = API.postFollowedList;
          } else {
            _postUrl = API.postList;
          }
        }
        break;
      case 'user':
        if (isMore) {
          _postUrl = '${API.postListByUid}'
              '${additionAttrs!['uid']}/id_max/$lastValue';
        } else {
          _postUrl = '${API.postListByUid}${additionAttrs!['uid']}';
        }
        break;
      case 'search':
        final String keyword = Uri.encodeQueryComponent(
          additionAttrs!['words'] as String,
        );
        if (isMore) {
          _postUrl = '${API.postListByWords}$keyword/id_max/$lastValue';
        } else {
          _postUrl = '${API.postListByWords}$keyword';
        }
        break;
      case 'mention':
        if (isMore) {
          _postUrl = '${API.postListByMention}/id_max/$lastValue';
        } else {
          _postUrl = API.postListByMention;
        }
        break;
    }
    return NetUtils.get<Map<String, dynamic>>(_postUrl);
  }

  static Future<Response<Map<String, dynamic>>> getForwardListInPost(
    int postId, {
    bool isMore = false,
    int? lastValue,
  }) {
    return NetUtils.get(
      '${API.postForwardsList}'
      '${isMore ? '$postId/id_max/$lastValue' : ''}',
    );
  }

  static Future<Response<dynamic>> glancePost(int postId) {
    return NetUtils.post<dynamic>(
      API.postGlance,
      data: <String, dynamic>{
        'tids': <int>[postId]
      },
    );
  }

  static Future<Response<Map<String, dynamic>>> deletePost(int postId) {
    return NetUtils.delete('${API.postContent}/tid/$postId');
  }

  static Future<Response<Map<String, dynamic>>> postForward(
    String content,
    int /*!*/ postId,
    bool replyAtTheMeanTime,
  ) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'content': Uri.encodeFull(content),
      'root_tid': postId,
      'reply_flag': replyAtTheMeanTime ? 3 : 0,
    };
    return NetUtils.post(API.postRequestForward, data: data);
  }

  /// Report content to specific account through message socket.
  ///
  /// Currently *145685* is '信息化中心用户服务'.
  static Future<void> reportPost(Post post) async {
    final String message = '————微博内容举报————\n'
        '举报时间：${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n'
        '举报对象：${post.nickname}\n'
        '微博ＩＤ：${post.id}\n'
        '发布时间：${post.postTime}\n'
        '举报理由：违反微博广场公约\n'
        '———From OpenJMU———';
    MessageUtils.addPackage(
      'WY_MSG',
      M_WY_MSG(type: 'MSG_A2A', uid: 145685, message: message),
    );
  }

  /// Convert [DateTime] to formatted string.
  /// 将时间转换为特定格式
  ///
  /// Rules combined with WeChat & Weibo & TikTok, are down below.
  /// 采用微信、微博和抖音的的时间处理混合方案，具体方案如下。
  ///
  /// 小于１分钟：　刚刚
  /// 小于１小时：　n分钟前
  /// 小于今天　：　n小时前
  /// 昨天　　　：　昨天HH:mm
  /// 小于４天　：　n天前
  /// 大于４天　：　MM-dd
  /// 去年及以前：　yy-MM-dd
  static String postTimeConverter(dynamic time) {
    assert(
      time is DateTime || time is String,
      'time must be DateTime or String type.',
    );
    final DateTime now = DateTime.now();
    DateTime? origin;
    if (time is String) {
      origin = DateTime.tryParse(time);
    } else if (time is DateTime) {
      origin = time;
    }
    if (origin == null) {
      throw ArgumentError.notNull('origin');
    }

    String _formatToYear(DateTime date) {
      return DateFormat('yyyy-MM-dd').format(date);
    }

    String _formatToMonth(DateTime date) {
      return DateFormat('MM-dd').format(date);
    }

    final Duration difference = now.difference(origin);
    if (difference <= 1.minutes) {
      return '刚刚';
    }
    if (difference < 60.minutes) {
      return '${difference.inMinutes}分钟前';
    }
    if (difference < 24.hours && origin.weekday == now.weekday) {
      return '${difference.inHours}小时前';
    }
    if (_formatToMonth(now - 1.days) == _formatToMonth(origin)) {
      return '昨天 ${DateFormat('HH:mm').format(origin)}';
    }
    if (difference <= 3.days) {
      return '${difference.inDays}天前';
    }
    if (difference > 3.days && now.year == origin.year) {
      return _formatToMonth(origin);
    }
    return _formatToYear(origin);
  }

  /// Create post publish request.
  /// 创建发布动态的请求
  static Future<Response<Map<String, dynamic>>> publishPost(
    Map<String, dynamic> content,
  ) {
    return NetUtils.post(API.postContent, data: content);
  }

  /// Create [FormData] for post's image upload.
  /// 创建用于发布动态上传的图片的 [FormData]
  static Future<FormData> createPostImageUploadForm(AssetEntity asset) async {
    final File? file = await asset.file;
    final String filename =
        file != null ? path.basename(file.path) : '$currentTimeStamp.jpg';
    final Uint8List? data = await compressEntity(
      asset,
      path.extension(filename),
    );
    if (data == null) {
      throw StateError('Error when obtaining image entity.');
    }
    return FormData.fromMap(<String, dynamic>{
      'image': MultipartFile.fromBytes(data, filename: filename),
      'image_type': 0,
    });
  }

  /// Create request for post's image upload.
  /// 创建用于发布动态时上传图片的请求
  static Future<Response<dynamic>> createPostImageUploadRequest(
    FormData formData,
    CancelToken cancelToken,
  ) {
    return NetUtils.post<dynamic>(
      API.postUploadImage,
      data: formData,
      cancelToken: cancelToken,
      options: Options(receiveTimeout: 60000, sendTimeout: 60000),
    );
  }
}
