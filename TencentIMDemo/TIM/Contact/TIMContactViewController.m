//
//  TIMContactViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMContactViewController.h"
#import <TUIContactController.h>
#import <TUIFriendProfileController.h>
#import <TUINewFriendViewController.h>
#import "TUIUserProfileController.h"
#import "TUIGroupConversationListController.h"
#import "TUIGroupChatViewController.h"

#import "TIMManager.h"

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

#pragma mark - TUIContactControllerListener
- (void)onSelectFriend:(TUICommonContactCell *)cell {
    TUICommonContactCellData *data = cell.contactData;
    TUIFriendProfileController *vc = [[TUIFriendProfileController alloc] init];
    vc.friendProfile = data.friendProfile;
    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
}

- (void)onAddNewFriend:(TUICommonTableViewCell *)cell {
    TUINewFriendViewController *vc = TUINewFriendViewController.new;
    vc.cellClickBlock = ^(TUICommonPendencyCell * _Nonnull cell) {
        TUIUserProfileController *controller = [[TUIUserProfileController alloc] init];
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.pendency = cell.pendencyData;
            controller.actionType = PCA_PENDENDY_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    [self.contactVC.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TUICommonTableViewCell *)cell {
    TUIGroupConversationListController *vc = TUIGroupConversationListController.new;
    @weakify(self)
    vc.onSelect = ^(TUICommonContactCellData * _Nonnull cellData) {
        @strongify(self)
        TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
        data.groupID = cellData.identifier;
        TUIGroupChatViewController *chatVc = [[TUIGroupChatViewController alloc] init];
        chatVc.conversationData = data;
        [self.navigationController pushViewController:chatVc animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
