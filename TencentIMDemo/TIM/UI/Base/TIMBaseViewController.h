//
//  TIMBaseViewController.h
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIMBaseViewController : UIViewController <JXCategoryListContentViewDelegate>

- (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END
