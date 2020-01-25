#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <UserNotifications/UserNotifications.h>
#import <Flutter/Flutter.h>
static NSString *SendTime;
static NSString *token;
static NSString *isAddToPushSuccess;
@implementation AppDelegate

-(NSString*) PushToken{
    return token;
}

-(NSString*) PushTime {
    return SendTime;
}

-(NSString*) PushSuccess{
    return isAddToPushSuccess;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel *iOSTokenChannel = [FlutterMethodChannel methodChannelWithName:@"cn.edu.jmu.openjmu/iOSPushToken" binaryMessenger:controller];
    [iOSTokenChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        
        if ([@"getPushToken" isEqualToString:call.method]) {
            if (token != nil) {
                result([self PushToken]);
            } else {
                result([FlutterError errorWithCode:@"01" message:[NSString stringWithFormat:@"异常"] details:@"进入tryCatchError"]);}
        } else {
            if ([@"getPushDate" isEqualToString:call.method]) {
                if (SendTime != nil) {
                    result([self PushTime]);
                } else {
                    result([FlutterError errorWithCode:@"02" message:[NSString stringWithFormat:@"异常"] details:@"进入tryCatchError"]);}
            }
            else {
                if ([@"getPushSuccess" isEqualToString:call.method]) {
                    if (isAddToPushSuccess != nil) {
                        result([self PushSuccess]);
                    } else {
                        result([FlutterError errorWithCode:@"03" message:[NSString stringWithFormat:@"异常"] details:@"进入tryCatchError"]); }
                } else {
                    result(FlutterMethodNotImplemented);
                }
            }
        }
        
        
    }];
    {
        // TODO:暂时还未实现的功能
        if (@available(iOS 10.0, *)) {
            
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"%@", error);
            }];
            UNNotificationCategory* generalCategory = [UNNotificationCategory
                                                    categoryWithIdentifier:@"GENERAL"
                                                    actions:@[]
                                                    intentIdentifiers:@[]
                                                    options:UNNotificationCategoryOptionCustomDismissAction];
            
            // Create the custom actions for expired timer notifications.
            UNNotificationAction* stopAction = [UNNotificationAction
                                            actionWithIdentifier:@"SNOOZE_ACTION"
                                            title:@"取消"
                                            options:UNNotificationActionOptionAuthenticationRequired];
            UNNotificationAction* forAction = [UNNotificationAction
                                            actionWithIdentifier:@"FOR_ACTION"
                                            title:@"进入OpenJMU"
                                            options:UNNotificationActionOptionForeground];
            
            // Create the category with the custom actions.
            UNNotificationCategory* expiredCategory = [UNNotificationCategory
                                                    categoryWithIdentifier:@"TIMER_EXPIRED"
                                                    actions:@[stopAction,forAction]
                                                    intentIdentifiers:@[]
                                                    options:UNNotificationCategoryOptionNone];
            
            // Register the notification categories.
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center setDelegate:self];
            [center setNotificationCategories:[NSSet setWithObjects:generalCategory, expiredCategory, nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            
        }
        return YES;
    }
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        NSString *host = webpageURL.host;
        if ([host isEqualToString:@"××××.openjmu.xyz"]) {
            // 判断域名是自己的网站，进行我们需要的处理
        } else {
            [[UIApplication sharedApplication]openURL:webpageURL];
        }
    }
    return YES;
}
#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
//    NSLog(@"%s", __func__);
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
//    NSLog(@"%s", __func__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = @(-1);
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"clearBadge" content:content trigger:0];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    NSDate *now = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    SendTime = [forMatter stringFromDate:now]; // 转换系统现在的时间
    NSString *tokenString = [[NSString alloc] initWithData:deviceToken encoding:NSSymbolStringEncoding];
    token = tokenString;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSData *) error{
    isAddToPushSuccess = @"Fail";
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
//    NSLog(@"Wait Open Url = %@",url);
    return YES;
}

@end
