//
//  TIMContactViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMContactViewController.h"
#import <TUIContactController.h>

@interface TIMContactViewController () <TUIContactControllerListener>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) TUIContactController *contactVC;

@end

@implementation TIMContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:@"联系人"];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    self.contactVC = [[TUIContactController alloc] init];
    self.contactVC.delegate = self;
    [self addChildViewController:self.contactVC];
    [self.view addSubview:self.contactVC.view];
    
    [self.contactVC.viewModel loadContacts];
}

@end
