//
//  TIMManager.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

static NSString * const TIMManagerUserId = @"TIMManagerUserId";
static NSString * const TIMManagerUserSig = @"TIMManagerUserSig";

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

@property (nonatomic, strong) NSHashTable *listeners;

@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *userSig;

@end

@implementation TIMManager

#pragma mark - Public

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSHashTable weakObjectsHashTable];
        [self loadLastLoginInfo];
    }
    return self;
}

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

- (void)addListener:(id <TIMManagerListenr>)listener {
    if (![self.listeners containsObject:listener]) {
        [self.listeners addObject:listener];
    }
}

- (void)removeListener:(id <TIMManagerListenr>)listener {
    if ([self.listeners containsObject:listener]) {
        [self.listeners removeObject:listener];
    }
}

- (V2TIMLoginStatus)getLoginStatus {
    return [[V2TIMManager sharedInstance] getLoginStatus];
}

- (void)loginWithUserId:(NSString *)userId userSig:(NSString *)userSig {
    if ([self getLoginStatus] == V2TIM_STATUS_LOGINING) {
        return;
    }
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userId]) {
        [self listenrsDidLoginWithUserId:userId];
        return;
    }
    if (userId.length == 0 || userSig.length == 0) {
        return;
    }
    @weakify(self)
    [[V2TIMManager sharedInstance] login:userId userSig:userSig succ:^{
        @strongify(self)
        [self saveLastLoginInfoWithUserId:userId userSig:userSig];
        [self listenrsDidLoginWithUserId:userId];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        [self listenrsDidLoginFailedWithCode:code description:desc];
    }];
}

- (void)tryAutoLogin {
    if (self.userId && self.userSig) {
        [self loginWithUserId:self.userId userSig:self.userSig];
    }
}

#pragma mark - Private

- (void)listenersOnConnecting {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnConnecting)]) {
            [listener timOnConnecting];
        }
    }
}

- (void)listenersOnConnectSuccess {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnConnectSuccess)]) {
            [listener timOnConnectSuccess];
        }
    }
}

- (void)listenersOnConnectFailed:(int)code error:(NSString*)error {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnConnectFailed:error:)]) {
            [listener timOnConnectFailed:code error:error];
        }
    }
}

- (void)listenersOnKickedOffline {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnKickedOffline)]) {
            [listener timOnKickedOffline];
        }
    }
}

- (void)listenersOnUserSigExpired {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnUserSigExpired)]) {
            [listener timOnUserSigExpired];
        }
    }
}

- (void)listenersOnSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timOnSelfInfoUpdated:)]) {
            [listener timOnSelfInfoUpdated:Info];
        }
    }
}

- (void)listenrsDidLoginWithUserId:(NSString *)userId {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timManagertimManager:didLoginWithUserId:)]) {
            [listener timManager:self didLoginWithUserId:userId];
        }
    }
}

- (void)listenrsDidLogutWithUserId:(NSString *)userId {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timManager:didLogoutWithUserId:)]) {
            [listener timManager:self didLogoutWithUserId:userId];
        }
    }
}

- (void)listenrsDidLoginFailedWithCode:(int)code description:(NSString *)description {
    for(id <TIMManagerListenr> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(timManagertimManager:didLoginFailedWithCode:description:)]) {
            [listener timManager:self didLoginFailedWithCode:code description:description];
        }
    }
}

- (void) saveLastLoginInfoWithUserId:(NSString *)userId userSig:(NSString *)userSig {
    self.userId= userId;
    self.userSig = userSig;
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:TIMManagerUserId];
    [[NSUserDefaults standardUserDefaults] setObject:userSig forKey:TIMManagerUserSig];
}

- (void)loadLastLoginInfo {
    self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:TIMManagerUserId];
    self.userSig = [[NSUserDefaults standardUserDefaults] objectForKey:TIMManagerUserSig];
}

#pragma mark - Getter / Setter

- (NSString *)loginUserID {
    return [V2TIMManager.sharedInstance getLoginUser];
}

#pragma mark - V2TIMSDKListener

/// SDK 正在连接到服务器
- (void)onConnecting {
#if DEBUG
    NSLog(@"TIM SDK 正在连接到服务器");
#endif
    [self listenersOnConnecting];
}

/// SDK 已经成功连接到服务器
- (void)onConnectSuccess {
#if DEBUG
    NSLog(@"TIM SDK 已经成功连接到服务器");
#endif
    [self onConnectSuccess];
}

/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString*)err {
#if DEBUG
    NSLog(@"TIM SDK 连接服务器失败: %@", err);
#endif
    [self listenersOnConnectFailed:code error:err];
}

/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline {
#if DEBUG
    NSLog(@"TIM SDK 当前用户被踢下线");
#endif
    [self listenersOnKickedOffline];
}

/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired {
#if DEBUG
    NSLog(@"TIM SDK 在线时票据过期");
#endif
    [self listenersOnUserSigExpired];
}

/// 当前用户的资料发生了更新
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info {
#if DEBUG
    NSLog(@"TIM SDK 当前用户的资料发生了更新");
#endif
    [self listenersOnSelfInfoUpdated:Info];
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
