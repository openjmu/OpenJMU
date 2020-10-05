//
//  AppDelegate.swift
//  Runner
//
//  Created by AlexV525 on 2020/10/5.
//

import UIKit
import Flutter

var sendTime: String = ""
var token: String = ""

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {
            let iOSTokenChannel = FlutterMethodChannel(
                name: "cn.edu.jmu.openjmu/iOSPushToken",
                binaryMessenger: controller.binaryMessenger
            )
                
        iOSTokenChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
                case "getPushToken":
                        if !token.isEmpty {
                            result(token)
                        } else {
                            result(FlutterError(
                                code: "01",
                                message: "获取 Token 异常",
                                details: "token 为空"
                            ))
                        }
                        break;
                    case "getPushDate":
                        if !sendTime.isEmpty {
                            result(sendTime)
                        } else {
                            result(FlutterError(
                                code: "02",
                                message: "获取 PushDate 异常",
                                details: "sendTime 为空"
                            ))
                        }
                        break;
                    default:
                        result(FlutterMethodNotImplemented)
                        break;
                }
            });
        }

        if #available(iOS 10, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            }
            let generalCategory = UNNotificationCategory.init(
                identifier: "GENERAL",
                actions: [],
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
            let stopAction = UNNotificationAction.init(
                identifier: "SNOOZE_ACTION",
                title: "取消",
                options: [.authenticationRequired]
            )
            let enterAction = UNNotificationAction.init(
                identifier: "ENTER_ACTION",
                title: "进入OpenJMU",
                options: [.foreground]
            )
            let expiredCategory = UNNotificationCategory.init(
                identifier: "TIMER_EXPIRED",
                actions: [stopAction, enterAction],
                intentIdentifiers: [],
                options: []
            )
            notificationCenter.delegate = self
            notificationCenter.setNotificationCategories(
                Set<UNNotificationCategory>(arrayLiteral: generalCategory, expiredCategory)
            )
            application.registerForRemoteNotifications()
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let now = Date()
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        sendTime = formatter.string(from: now)
        token = deviceToken.reduce("") { $0 + String(format: "%02.2hhx", $1) }
    }
}
