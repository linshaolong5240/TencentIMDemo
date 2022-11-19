//
//  TIMLoginViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMLoginViewController.h"
#import <Masonry/Masonry.h>
#import "TIMManager.h"

@interface TIMLoginViewController ()

@property(nonatomic, strong) UITextField *userIdField;
@property(nonatomic, strong) UIButton *loginButton;

@end

@implementation TIMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureView];
}

- (void)configureView {
    UITextField *userIdField = [[UITextField alloc] init];
    userIdField.placeholder = @"userid";
    userIdField.backgroundColor = UIColor.blueColor;
    [self.view addSubview:userIdField];
    [userIdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.right.equalTo(self.view).inset(20);
        make.height.equalTo(@44);
    }];
    self.userIdField = userIdField;
    
    UIButton *loginButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    loginButton.backgroundColor = UIColor.blueColor;
    [loginButton setTitle:@"Login" forState:(UIControlStateNormal)];
    [loginButton addTarget:self action:@selector(login) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userIdField.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.left.right.equalTo(self.view).inset(20);
        make.height.equalTo(@44);
    }];
    self.loginButton = loginButton;
}

- (void)login {
    [TIMManager.sharedInstance loginWithUserId:@"1234" userSig:@"eJwtzEELgjAYxvHvsmth75zbVPDgJYi62aKgi7gpL5WOKcOIvnumHp-fA-8POZ*KwBtHUhIGQLbzRm3aAWucmYYsWr3Xj9Ja1CSlEYDkSSLo8pjRojOTc85DAFh0wNffhIgllxCztYLNlEVXXfL9tb-vemo6rN3oyyd7NwVtWXfzeZUcFVcH1qpNnJHvD8i7MOQ_"];
}

@end
