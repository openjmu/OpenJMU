import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/constants/Constants.dart';

class Messages {
  static final Map<String, dynamic> socketConfig = {
    "host": "210.34.130.61",
    "port": 7777,
  };

  static Map<String, int> messageCommands = {
    "WY_VERIFY_CHECKCODE": 0x75, // Session验证
    "WY_MULTPOINT_LOGIN": 0x9000, // 用户登陆
    "WY_LOGOUT": 0x9, // 用户退出
    "WY_CHANGE_STATUS": 0x10, // 改变状态
    "WY_KEEPALIVE": 0x11, // 心跳
    "WY_GET_OFFLINEMSG": 0x77, // 获取离线消息
    "WY_MSG": 0x20, // 发送消息
    "WY_OL_NUM": 0x28, // 获取在线人数
  };

  static Map<String, Function> messagePacks = {
    "WY_VERIFY_CHECKCODE": () => [
          ...MessageUtils.commonString(UserAPI.currentUser.sid), // Session ID
        ],
    "WY_MULTPOINT_LOGIN": () => [
          ...MessageUtils.commonUint(0, 16), // 状态值
          ...MessageUtils.commonString(ascii.decode([0, 0, 0, 0x24, 0])), // 状态描述
          ...MessageUtils.commonUint(1, 8), // 是否多点登录 (0/1)
          ...MessageUtils.commonString(
            "${Constants.appId}|${DeviceUtils.deviceModel}|||V",
          ), // 登录点描述
          ...MessageUtils.commonUint(1, 16), // (可选，默认0) 心跳检测频率 = n * 60
          ...MessageUtils.commonUint(55, 32), // 单位id (55)
          ...MessageUtils.commonUint(1, 8), // 是否移动端 (0/1)
        ],
  };

  static const Map<String, int> PRPL_91U_MSG_TYPE = {
    "MSG_A2A": 0, // 普通聊天
    "MSG_AUTH_ACCEPTED": 1, // 加好友验证通过
    "MSG_AUTH_REJECTED": 3, // 加好友拒绝验证
    "MSG_ADDED": 4, // 被别人加为好友
    "MSG_DELETED": 5, // 被别人从好友列表中删除
    "MSG_A2A_ENCRYPT": 10, // 加密的普通聊天
    "MSG_A2A_RETURN_RECEIPT": 11, // 消息回执
    "MSG_FLOWER_MSG": 20, // 送花答谢或索花留言
    "MSG_UPLOAD_USER_LOG": 21, // 需要上传用户日志（json）
    "MSG_AUTH_REQUEST": 65, // 加好友验证请求
    "MSG_IN_JSON_FROM_ORG": 100, // 应用 JSON 消息，即将废弃以后统一转到 XML 格式
    "MSG_IN_XML_FROM_ORG": 101, // 应用 XML 消息
    "MSG_A2A_TYPING": 193, // 正在输入的通知
    "MSG_A2A_AUTO_REPLY": 195, // 自动回复消息
    "MSG_A2A_SHAKE_WINDOW": 196, // 抖动窗口
    "MSG_A2A_UPLOAD_FINISHED": 197, // （图片）上传完成
    "MSG_IN_JSON_FROM_ORG_NO_OFFLINE":
        200, // ORG 的 JSON 消息（不记离线），即将废弃以后统一转到 XML 格式
    "MSG_IN_XML_FROM_ORG_NO_OFFLINE": 201, // 应用 XML 消息（不记离线）
    "MSG_NEW_CONV_SOURCE_NOTIFY":
        202, // 新会话来源通知 格式为显示的来源字符串（e.g. " 来自 xx 群的会话 "）
    "MSG_A2A_QA_BEGIN": 203, // 答疑开始
    "MSG_A2A_QA_END": 204, // 答疑结束
    "MSG_NOOP": 255,
  };

  static const Map<String, int> _GroupType = {
    "GROUP_TYPE_NORMAL": 0, // 普通群
    "GROUP_TYPE_CHATROOM": 1, // 聊天室
    "GROUP_TYPE_DISCUSS": 2, // 讨论组
    "GROUP_TYPE_ORG": 10, // 组织群
    "GROUP_TYPE_ORG_CHATROOM": 11, // 组织聊天室
    "GROUP_TYPE_CLASS": 12, // 班级群
    "GROUP_TYPE_GRADE": 14, // 年段群
    "GROUP_TYPE_HEADLINE": 20, // 单位系统公告群
    "GROUP_TYPE_VIDEOCONFERENCE_ROOM": 30, //视频会议
    "GROUP_TYPE_PSP": 40, //公众服务
    "GROUP_TYPE_MASK": 0xFF,
    "GROUP_TYPE_FLAG_OAP": 0x0000, // OAP
    "GROUP_TYPE_FLAG_UAP": 0x1000, // UAP
    "GROUP_TYPE_FLAG_CLASSMATE": 0x2000, // 个人版校友
    "GROUP_TYPE_FLAG_NEWUAP": 0x3000, // NEWUAP
  };

  static final String inputting = "inputing now";
}

///
/// 命令请求内容体抽象类
/// [requestBody] 请求内容生成方法，重写并调用该方法获得转换内容
///
abstract class MessageRequest {
  List<int> requestBody();
}

///
/// 命令接收内容体抽象类
/// [responseBody] 接收内容解析方法，重写并调用该方法获得实际内容
///
abstract class MessageResponse {
  Map<String, dynamic> responseBody(List<int> response);
}

class M_WY_MSG implements MessageRequest {
  String type;
  int uid;
  String message;

  M_WY_MSG({
    @required this.type,
    @required this.uid,
    @required this.message,
  });

  @override
  List<int> requestBody() {
    final result = [
      ...MessageUtils.commonUint(Messages.PRPL_91U_MSG_TYPE[type], 8),
      ...MessageUtils.commonUint(uid, 64),
      ...MessageUtils.commonString("$message"),
    ];
    return result;
  }
}

class R_WY_MSG implements MessageResponse {
  @override
  Map<String, dynamic> responseBody(List<int> response) {
    return null;
  }
}
