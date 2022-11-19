//
//  TIMManager.h
//  TencentIMDemo
//
//  Created by Saruon on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK_Plus/ImSDK_Plus.h>

@class TIMManager;

NS_ASSUME_NONNULL_BEGIN

NSString *NSStringFromV2TIMLoginStatus(V2TIMLoginStatus status);

@protocol TIMManagerListenr <NSObject>

@optional

- (void)imManager:(TIMManager *)manager didLoginWithUserId:(NSString *)userId;
- (void)imManager:(TIMManager *)manager didLoginFailedWithCode:(int)code description:(NSString *)description;

@end

@interface TIMManager : NSObject

@property(nonatomic, assign) BOOL directlyLoginEnabled;

@property(nullable ,nonatomic, readonly, copy) NSString *loginUserID;

+ (instancetype)sharedInstance;

- (void)initSDKWithAppId:(int)AppId;
- (void)initSDKWithAppId:(int)AppId config:(V2TIMSDKConfig *)config;
- (void)addListener:(id <TIMManagerListenr>)listener;
- (void)removeListener:(id <TIMManagerListenr>)listener;
- (V2TIMLoginStatus)getLoginStatus;
- (void)loginWithUserId:(NSString *)userId userSig:(NSString *)userSig;
- (void)tryAutoLogin;

@end

NS_ASSUME_NONNULL_END
