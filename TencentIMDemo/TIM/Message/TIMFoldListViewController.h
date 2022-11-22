//
//  TIMFoldListViewController.h
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIMFoldListViewController : UIViewController

@property (nonatomic,copy) void(^dismissCallback)(NSMutableAttributedString * foldStr,NSArray *sortArr, NSArray *needRemoveFromCacheMapArray);

@end

NS_ASSUME_NONNULL_END
