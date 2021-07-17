import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show HTTPCookieSameSitePolicy;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

// ignore: implementation_imports
import 'package:extended_image_library/src/_network_image_io.dart';

import 'package:openjmu/constants/constants.dart';

UserInfo get currentUser => UserAPI.currentUser;

set currentUser(UserInfo user) {
  if (user == null) {
    return;
  }
  UserAPI.currentUser = user;
}

class UserAPI {
  const UserAPI._();

  static UserInfo currentUser = const UserInfo();

  static List<Cookie> cookiesForJWGL;

  static Map<String, BackpackItemType> backpackItemTypes =
      <String, BackpackItemType>{};

  static Future<Response<Map<String, dynamic>>> login(
    Map<String, dynamic> params,
  ) {
    return NetUtils.tokenDio.post(API.login, data: params);
  }

  static Future<void> logout(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '退出登录',
      showConfirm: true,
      content: '您正在退出账号，请确认操作',
    );
    if (confirm) {
      NetUtils.dio.clear();
      NetUtils.tokenDio.clear();
      Instances.eventBus.fire(LogoutEvent());
    }
  }

  /// Update cache network image provider after avatar is updated.
  static int avatarLastModified = currentTimeStamp;

  static ExtendedNetworkImageProvider getAvatarProvider({
    String uid,
    int t,
    int size,
  }) {
    return ExtendedNetworkImageProvider(
      '${API.userAvatar}'
      '?uid=${uid ?? currentUser.uid}'
      '&_t=${t ?? avatarLastModified}'
      '&size=f${size ?? 152}',
      cache: true,
      cacheKey: '${uid ?? currentUser.uid}_${t ?? avatarLastModified}',
      cacheRawData: true,
    );
  }

  static void updateAvatarProvider() {
    ExtendedNetworkImageProvider(
      '${API.userAvatar}'
      '?uid=${currentUser.uid}'
      '&size=f152'
      '&_t=$avatarLastModified',
    ).evict();
    ExtendedNetworkImageProvider(
      '${API.userAvatar}'
      '?uid=${currentUser.uid}'
      '&size=f640'
      '&_t=$avatarLastModified',
    ).evict();
    avatarLastModified = currentTimeStamp;
  }

  static Future<dynamic> getUserInfo({String uid}) async {
    if (uid == null) {
      return currentUser;
    } else {
      return NetUtils.get<dynamic>(
        API.userInfo,
        queryParameters: <String, dynamic>{'uid': uid},
      );
    }
  }

  static Future<Response<Map<String, dynamic>>> getStudentInfo({
    String uid,
  }) async {
    return NetUtils.get<Map<String, dynamic>>(
        API.studentInfo(uid: uid ?? currentUser.uid));
  }

  static Future<Response<Map<String, dynamic>>> getLevel(String uid) {
    return NetUtils.get(API.userLevel(uid: uid));
  }

  static Future<Response<Map<String, dynamic>>> getTags(String uid) {
    return NetUtils.get(
      API.userTags,
      queryParameters: <String, dynamic>{'uid': uid},
    );
  }

  static Future<Response<Map<String, dynamic>>> getFans(String uid) {
    return NetUtils.get('${API.userFans}$uid');
  }

  static Future<Response<Map<String, dynamic>>> getIdols(String uid) {
    return NetUtils.get('${API.userIdols}$uid');
  }

  static Future<Response<Map<String, dynamic>>> getFansList(
    String uid,
    int page,
  ) {
    return NetUtils.get(
      '${API.userFans}$uid/page/$page/page_size/20',
    );
  }

  static Future<Response<Map<String, dynamic>>> getIdolsList(
    String uid,
    int page,
  ) {
    return NetUtils.get(
      '${API.userIdols}$uid/page/$page/page_size/20',
    );
  }

  static Future<Response<Map<String, dynamic>>> getFansAndFollowingsCount(
    String uid,
  ) {
    return NetUtils.get('${API.userFansAndIdols}$uid');
  }

  static Future<Response<Map<String, dynamic>>> getNotifications() async =>
      NetUtils.get<Map<String, dynamic>>(API.postUnread);

  static Future<bool> follow(String uid) async {
    try {
      await NetUtils.post<dynamic>('${API.userRequestFollow}$uid');
      await NetUtils.post<dynamic>(
        API.userFollowAdd,
        data: <String, dynamic>{'fid': uid, 'tagid': 0},
      );
      Instances.eventBus.fire(UserFollowEvent(uid: uid, isFollow: true));
      showToast('关注成功');
      return true;
    } catch (e) {
      LogUtils.e('Failed when folloe: $e');
      showCenterErrorToast('关注失败');
      return false;
    }
  }

  static Future<bool> unFollow(String uid, {bool fromBlacklist = false}) async {
    try {
      await NetUtils.delete<dynamic>(
        '${API.userRequestFollow}$uid',
      );
      await NetUtils.post<dynamic>(
        API.userFollowAdd,
        data: <String, dynamic>{'fid': uid},
      );
      Instances.eventBus.fire(UserFollowEvent(uid: uid, isFollow: false));
      if (!fromBlacklist) {
        showToast('已取消关注');
      }
      return true;
    } catch (e) {
      LogUtils.e('Failed when unfollow $uid: $e');
      if (!fromBlacklist) {
        showCenterErrorToast('取消关注失败');
      }
      return false;
    }
  }

  static Future<Response<Map<String, dynamic>>> setSignature(
    String content,
  ) async {
    return NetUtils.post(
      API.userSignature,
      data: <String, dynamic>{'signature': content},
    );
  }

  static Future<Map<String, dynamic>> searchUser(String name) async {
    Map<String, dynamic> users = (await NetUtils.get<Map<String, dynamic>>(
      API.searchUser,
      queryParameters: <String, dynamic>{'keyword': name},
    ))
        .data;
    if (users['total'] == null) {
      users = <String, dynamic>{
        'total': 1,
        'data': <Map<String, dynamic>>[users]
      };
    }
    return users;
  }

  /// 获取背包物品的类型
  static Future<void> getBackpackItemType() async {
    try {
      final Map<String, dynamic> types =
          (await NetUtils.get<Map<String, dynamic>>(
        API.backPackItemType,
        headers: <String, dynamic>{'CLOUDID': 'jmu'},
      ))
              .data;
      final List<dynamic> items = types['data'] as List<dynamic>;
      for (int i = 0; i < items.length; i++) {
        final BackpackItemType item =
            BackpackItemType.fromJson(items[i] as Map<String, dynamic>);
        backpackItemTypes['${item.type}'] = item;
      }
    } catch (e) {
      LogUtils.e('Error when getting backpack item type: $e');
    }
  }

  /// Blacklists.
  static final Set<BlacklistUser> blacklist = <BlacklistUser>{};

  static Future<Response<Map<String, dynamic>>> getBlacklist({
    int pos = 0,
    int size = 20,
  }) {
    return NetUtils.tokenDio.get(
      API.blacklist,
      queryParameters: <String, dynamic>{'pos': pos, 'size': size},
    );
  }

  static Future<void> confirmBlock(
    BuildContext context,
    BlacklistUser user,
  ) async {
    final bool add = !UserAPI.blacklist.contains(user);
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '${add ? '加入' : '移出'}黑名单',
      content: add
          ? '将 ta 加入黑名单后您将无法收看 ta 的动态、'
              '接收到 ta 的信息，'
              '请确认操作'
          : '确定将此人移出黑名单吗?',
      showConfirm: true,
    );
    if (confirm) {
      if (add) {
        UserAPI.fAddToBlacklist(user);
      } else {
        UserAPI.fRemoveFromBlacklist(user);
      }
    }
  }

  static void fAddToBlacklist(BlacklistUser user) {
    if (blacklist.contains(user)) {
      showToast('仇恨值拉满啦！不要重复屏蔽噢~');
    } else {
      NetUtils.post<Map<String, dynamic>>(
        API.addToBlacklist,
        data: <String, dynamic>{'fid': user.uid},
      ).then((Response<Map<String, dynamic>> _) {
        blacklist.add(user);
        showToast('加入黑名单成功');
        Instances.eventBus.fire(BlacklistUpdateEvent());
        unFollow(user.uid, fromBlacklist: true);
      }).catchError((dynamic e) {
        showToast('加入黑名单失败');
        LogUtils.e('Add $user to blacklist failed : $e');
      });
    }
  }

  static void fRemoveFromBlacklist(BlacklistUser user) {
    blacklist.remove(user);
    showToast('移出黑名单成功');
    Instances.eventBus.fire(BlacklistUpdateEvent());
    NetUtils.post<dynamic>(
      API.removeFromBlacklist,
      data: <String, dynamic>{'fid': user.uid},
    ).catchError((dynamic e) {
      showToast('移出黑名单失败');
      LogUtils.e('Remove $user from blacklist failed: $e');
      if (blacklist.contains(user)) {
        blacklist.remove(user);
      }
      Instances.eventBus.fire(BlacklistUpdateEvent());
    });
  }

  static Future<void> initializeBlacklist() async {
    final Response<Map<String, dynamic>> res = await UserAPI.getBlacklist();
    final Map<String, dynamic> data = res.data;
    final List<dynamic> list = data['users'] as List<dynamic>;
    if (list.isNotEmpty) {
      for (final Map<dynamic, dynamic> person
          in list.cast<Map<dynamic, dynamic>>()) {
        final BlacklistUser user = BlacklistUser.fromJson(
          person as Map<String, dynamic>,
        );
        blacklist.add(user);
      }
    }
  }

  static Future<String> webVpnIsLogin() async {
    try {
      final Response<String> _res = await NetUtils.tokenDio.get(API.webVpnHost);
      final String r = _res.data;
      // 解析返回内容。如果包含「退出登录」，同时不包含「登录 Login」，即为已登录。
      if (r.contains('退出登录') && !r.contains('登录 Login')) {
        return null;
      }
      return r;
    } catch (e) {
      LogUtils.e('Error when testing WebVPN login status: $e');
      return '';
    }
  }

  /// Return `null` if succeed, and failed reason if failed.
  static Future<String> webVpnLogin() async {
    try {
      final String r = await webVpnIsLogin();
      if (r == null) {
        return null;
      }
      final dom.Document document = parse(r);
      final dom.Element tokenElement = document.querySelector(
        'input[name="authenticity_token"]',
      );
      if (tokenElement?.attributes == null) {
        return null;
      }
      final String token = tokenElement?.attributes['value'];
      if (token != null) {
        return null;
      }
      await HiveFieldUtils.setWebVpnToken(token);

      final UPModel upModel = HiveBoxes.upBox.getAt(0);
      final Response<String> loginRes = await NetUtils.tokenDio.post<String>(
        '${API.webVpnHost}/users/sign_in',
        queryParameters: <String, String>{
          'utf8': '✓',
          'authenticity_token': token,
          'user[login]': upModel.u,
          'user[password]': upModel.p,
          'user[dymatice_code]': 'unknown',
          'user[otp_with_capcha]': 'false',
          'commit': '登录 Login',
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      await _setVPNsValues(loginRes);
      return null;
    } on DioError catch (dioError) {
      if (dioError.response.statusCode == HttpStatus.found) {
        return await webVpnUpdate();
      } else {
        LogUtils.e('Failed to login WebVPN: $dioError');
        await _clearVPNsValues();
        return dioError.toString();
      }
    } catch (e) {
      LogUtils.e('Error when login to WebVPN: $e');
      await _clearVPNsValues();
      return e.toString();
    }
  }

  static Future<String> webVpnUpdate() async {
    try {
      final Response<String> res = await NetUtils.tokenDio.get<String>(
        '${API.webVpnHost}/vpn_key/update',
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      await _setVPNsValues(res);
      return null;
    } on DioError catch (dioError) {
      if (dioError.response.statusCode == HttpStatus.found) {
        await _setVPNsValues(dioError.response);
        return null;
      } else {
        await _clearVPNsValues();
        LogUtils.e('Failed to login WebVPN: $dioError');
        return dioError.toString();
      }
    } catch (e) {
      await _clearVPNsValues();
      LogUtils.e('Error when login to WebVPN: $e');
      return e.toString();
    }
  }

  static Future<void> _setVPNsValues(Response<dynamic> res) async {
    final List<Cookie> cookies = <Cookie>[
      ...res.headers['set-cookie']
          .map((String s) => Cookie.fromSetCookieValue(s))
          .toList(),
      Cookie('SERVERID', 'Server1'),
    ];
    await Future.wait(<Future<void>>[
      NetUtils.updateDomainsCookies(
        <String>[
          'http://www.jmu.edu.cn/',
          'https://www.jmu.edu.cn/',
          'https://webvpn.jmu.edu.cn/',
        ],
        cookies,
      ),
      for (final Cookie cookie in cookies)
        NetUtils.webViewCookieManager.setCookie(
          url: Uri.parse('http://www.jmu.edu.cn/'),
          name: cookie.name,
          value: cookie.value,
          domain: 'webvpn.jmu.edu.cn',
          path: cookie.path ?? '/',
          isSecure: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        ),
      for (final Cookie cookie in cookies)
        NetUtils.webViewCookieManager.setCookie(
          url: Uri.parse('https://www.jmu.edu.cn/'),
          name: cookie.name,
          value: cookie.value,
          domain: 'webvpn.jmu.edu.cn',
          path: cookie.path ?? '/',
          isSecure: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        ),
      for (final Cookie cookie in cookies)
        NetUtils.webViewCookieManager.setCookie(
          url: Uri.parse('http://webvpn.jmu.edu.cn/'),
          name: cookie.name,
          value: cookie.value,
          domain: 'webvpn.jmu.edu.cn',
          path: cookie.path ?? '/',
          isSecure: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        ),
      for (final Cookie cookie in cookies)
        NetUtils.webViewCookieManager.setCookie(
          url: Uri.parse('https://webvpn.jmu.edu.cn/'),
          name: cookie.name,
          value: cookie.value,
          domain: 'webvpn.jmu.edu.cn',
          path: cookie.path ?? '/',
          isSecure: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        ),
    ]);
  }

  static Future<void> _clearVPNsValues() => HiveFieldUtils.setWebVpnToken(null);
}
