//
//  AppDelegate.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/17.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "TIMManager.h"
#import "TIMLoginViewController.h"
#import <TUIDefine.h>
#import <TUIThemeManager.h>
#import <TUIOfflinePushManager+Advance.h>

#import "TIMTabbarController.h"

@interface AppDelegate () <TIMManagerListenr>

@end

@implementation AppDelegate

#if 0
// 配置开发环境证书
TUIOfflinePushCertificateIDForAPNS(36093)
#else
// 配置生产环境证书
TUIOfflinePushCertificateIDForAPNS(36102)
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 自定义修改 TUIChat 组件的主题 - 修改主题资源包中的内置主题
    // -- 1. 获取自定义后的资源包路径
    // -- 2. 给 TUIChat 组件注册自定义的主题资源包路径，用于覆盖内置的主题，note: 此时只能覆盖 TUIThemeModuleChat
    TUIRegisterThemeResourcePath([NSBundle.mainBundle pathForResource:@"TUICoreCustomTheme.bundle" ofType:nil], TUIThemeModuleCore);
    [TUIThemeManager.shareManager applyTheme:@"tim" forModule:TUIThemeModuleCore];
    
    TUIRegisterThemeResourcePath([NSBundle.mainBundle pathForResource:@"TUIConversationCustomTheme.bundle" ofType:nil], TUIThemeModuleConversation);
    [TUIThemeManager.shareManager applyTheme:@"tim" forModule:TUIThemeModuleConversation];

    TUIRegisterThemeResourcePath([NSBundle.mainBundle pathForResource:@"TUIChatCustomTheme.bundle" ofType:nil], TUIThemeModuleChat);
    [TUIThemeManager.shareManager applyTheme:@"tim" forModule:TUIThemeModuleChat];
    
    TUIRegisterThemeResourcePath([NSBundle.mainBundle pathForResource:@"TUIDemoTheme.bundle" ofType:nil], TUIThemeModuleDemo);
    [TUIThemeManager.shareManager applyTheme:@"tim" forModule:TUIThemeModuleDemo];

    [TIMManager.sharedInstance addListener:self];
    [[TIMManager sharedInstance] initSDKWithAppId:1400759961];
    [TIMManager.sharedInstance tryAutoLogin];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    UIViewController *rootViewController = [TIMTabbarController new];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - TIMManagerListenr

- (void)timOnConnecting { }
- (void)timOnConnectSuccess { }
- (void)timOnConnectFailed:(int)code error:(NSString*)error { }
- (void)timOnKickedOffline {
    [TUIOfflinePushManager.shareManager unregisterService];
    UIViewController *rootViewController = [[UINavigationController alloc] initWithRootViewController:[TIMLoginViewController new]];
    self.window.rootViewController = rootViewController;
}
- (void)timOnUserSigExpired { }
- (void)timOnSelfInfoUpdated:(V2TIMUserFullInfo *)Info { }

- (void)timManager:(TIMManager *)manager didLoginWithUserId:(NSString *)userId {
    TIMTabbarController *tabBarController = (TIMTabbarController *)self.window.rootViewController;
    tabBarController.selectedViewController = tabBarController.viewControllers[1];
}

- (void)timManager:(TIMManager *)manager didLogoutWithUserId:(NSString *)userId {
    [TUIOfflinePushManager.shareManager unregisterService];
}

- (void)timManager:(TIMManager *)manager didLoginFailedWithCode:(int)code description:(NSString *)description {
}

@end
