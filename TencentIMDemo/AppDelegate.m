//
//  AppDelegate.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/17.
//

#import "AppDelegate.h"
#import "TIMManager.h"
#import "TIMLoginViewController.h"
#import "TIMHomeViewController.h"
#import <TUICommonModel.h>

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

#pragma mark - TIMManagerListenr

- (void)imManager:(TIMManager *)manager didLoginWithUserId:(NSString *)userId {
#if DEBUG
    NSLog(@"%s userId: %@", __PRETTY_FUNCTION__, userId);
    NSLog(@"LoginStatus: %@", NSStringFromV2TIMLoginStatus([TIMManager.sharedInstance getLoginStatus]));
#endif
    UIViewController *rootViewController = [[TUINavigationController alloc] initWithRootViewController:[TIMHomeViewController new]];
    self.window.rootViewController = rootViewController;
}

- (void)imManager:(TIMManager *)manager didLoginFailedWithCode:(int)code description:(NSString *)description {
#if DEBUG
    NSLog(@"%s code: %d description: %@", __PRETTY_FUNCTION__, code, description);
#endif
}

#pragma mark - UISceneSession lifecycle

//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}


//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
