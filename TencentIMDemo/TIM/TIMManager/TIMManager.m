//
//  TIMManager.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMManager.h"

static NSString * const TIMManagerKeyDirectlyLoginEnabled = @"TIMManagerKeyDirectlyLoginEnabled";

NSString *NSStringFromV2TIMLoginStatus(V2TIMLoginStatus status) {
    switch (status) {
        case V2TIM_STATUS_LOGINED:
            return @"已登录";
            break;
        case V2TIM_STATUS_LOGINING:
            return @"登录中";
            break;
        case V2TIM_STATUS_LOGOUT:
            return @"无登录";
            break;
    }
}

@interface TIMManager () <V2TIMSDKListener>

@end

@implementation TIMManager

#pragma mark - Public

+ (instancetype)sharedInstance {
    static TIMManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TIMManager alloc] init];
    });
    
    return shared;
}

- (void)initSDKWithAppId:(int)AppId {
    // 2. 初始化 config 对象
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    // 3. 指定 log 输出级别。
    config.logLevel = V2TIM_LOG_INFO;
    // 设置 log 监听器
    config.logListener = ^(V2TIMLogLevel logLevel, NSString *logContent) {
        // logContent 为 SDK 日志内容
#if DEBUG
        //        NSLog(@"%@", logContent);
#endif
    };
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    [[V2TIMManager sharedInstance] initSDK:AppId config:config];
}

- (void)initSDKWithAppId:(int)AppId config:(V2TIMSDKConfig *)config {
    [[V2TIMManager sharedInstance] addIMSDKListener:self];
    [[V2TIMManager sharedInstance] initSDK:AppId config:config];
}

- (void)deInitSDK {
    // self 是 id<V2TIMSDKListener> 的实现类
    [[V2TIMManager sharedInstance] removeIMSDKListener:self];
    // 反初始化 SDK
    [[V2TIMManager sharedInstance] unInitSDK];
}

- (void)loginWithUserId:(NSString *)userId userSig:(NSString *)userSig {
    if ([self getLoginStatus] == V2TIM_STATUS_LOGINING) {
        return;
    }
    [[V2TIMManager sharedInstance] login:userId userSig:userSig succ:^{
        if ([self.delegate respondsToSelector:@selector(manager:didLoginWithUserId:)]) {
            [self.delegate manager:self didLoginWithUserId:userId];
        }
    } fail:^(int code, NSString *desc) {
        if ([self.delegate respondsToSelector:@selector(manager:didLoginFailedWithCode:description:)]) {
            [self.delegate manager:self didLoginFailedWithCode:code description:desc];
        }
    }];
}

- (V2TIMLoginStatus)getLoginStatus {
    return [[V2TIMManager sharedInstance] getLoginStatus];
}

#pragma mark - Getter / Setter

- (BOOL)directlyLoginEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:TIMManagerKeyDirectlyLoginEnabled];
}

- (void)setDirectlyLoginEnabled:(BOOL)directlyLoginEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:directlyLoginEnabled forKey:TIMManagerKeyDirectlyLoginEnabled];
}

- (NSString *)loginUserID {
    return [V2TIMManager.sharedInstance getLoginUser];
}

#pragma mark - V2TIMSDKListener

/// SDK 正在连接到服务器
- (void)onConnecting {
#if DEBUG
    NSLog(@"TIM SDK 正在连接到服务器");
#endif
}

/// SDK 已经成功连接到服务器
- (void)onConnectSuccess {
#if DEBUG
    NSLog(@"TIM SDK 已经成功连接到服务器");
#endif
}

/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString*)err {
#if DEBUG
    NSLog(@"TIM SDK 连接服务器失败: %@", err);
#endif
}

/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline {
#if DEBUG
    NSLog(@"TIM SDK 当前用户被踢下线");
#endif
}

/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired {
#if DEBUG
    NSLog(@"TIM SDK 在线时票据过期");
#endif
}

/// 当前用户的资料发生了更新
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
#if DEBUG
    NSLog(@"TIM SDK 当前用户的资料发生了更新");
#endif
}

/**
 * 用户状态变更通知
 *
 * @note 收到通知的情况：
 * 1. 订阅过的用户发生了状态变更（包括在线状态和自定义状态），会触发该回调
 * 2. 在 IM 控制台打开了好友状态通知开关，即使未主动订阅，当好友状态发生变更时，也会触发该回调
 * 3. 同一个账号多设备登录，当其中一台设备修改了自定义状态，所有设备都会收到该回调
 */
- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList {
#if DEBUG
    NSLog(@"TIM SDK 用户状态变更通知");
#endif
}

@end
