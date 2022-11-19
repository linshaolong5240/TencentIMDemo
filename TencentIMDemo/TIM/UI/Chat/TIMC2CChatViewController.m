//
//  TIMC2CChatViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/19.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMC2CChatViewController.h"
#import <TUIChat.h>

@interface TIMC2CChatViewController ()

@end

@implementation TIMC2CChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TUIC2CChatViewController *chatVC = [[TUIC2CChatViewController alloc] init];
    [self addChildViewController:chatVC];
    [self.view addSubview:chatVC.view];
}

@end
