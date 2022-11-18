//
//  TIMBaseViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMBaseViewController.h"

@interface TIMBaseViewController ()

@end

@implementation TIMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

@end
