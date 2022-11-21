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
#import "TIMHomeViewController.h"
#import <TUICommonModel.h>
#import <TUIOfflinePushManager+Advance.h>

@interface AppDelegate () <TIMManagerListenr>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [TIMManager.sharedInstance addListener:self];
    [[TIMManager sharedInstance] initSDKWithAppId:1400759961];
    
    [TIMManager.sharedInstance tryAutoLogin];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    UIViewController *rootViewController = [[UINavigationController alloc] initWithRootViewController:[TIMLoginViewController new]];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = [[UINavigationController alloc] initWithRootViewController:[TIMLoginViewController new]];
        self.window.rootViewController = rootViewController;
    });
}
- (void)timOnUserSigExpired { }
- (void)timOnSelfInfoUpdated:(V2TIMUserFullInfo *)Info { }


- (void)timManager:(TIMManager *)manager didLoginWithUserId:(NSString *)userId {
    [TUIOfflinePushManager.shareManager registerService];
    UIViewController *rootViewController = [[TUINavigationController alloc] initWithRootViewController:[TIMHomeViewController new]];
    self.window.rootViewController = rootViewController;
}

- (void)timManager:(TIMManager *)manager didLogoutWithUserId:(NSString *)userId {
    [TUIOfflinePushManager.shareManager unregisterService];
}

- (void)timManager:(TIMManager *)manager didLoginFailedWithCode:(int)code description:(NSString *)description {
}

@end
