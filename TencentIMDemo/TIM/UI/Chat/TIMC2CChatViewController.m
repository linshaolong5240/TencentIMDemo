//
//  TIMC2CChatViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/19.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMC2CChatViewController.h"
#import <TUIC2CChatViewController.h>

@interface TIMC2CChatViewController ()

@property(nonatomic, strong) TUIC2CChatViewController *chatVC;

@end

@implementation TIMC2CChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.chatVC = [[TUIC2CChatViewController alloc] init];
    [self addChildViewController:self.chatVC];
    [self.view addSubview:self.chatVC.view];
}

- (void)setConversation:(TUIChatConversationModel *)conversationData {
    self.chatVC.conversationData = conversationData;
}

@end
