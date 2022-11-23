//
//  TIMHomeViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/17.
//

#import "TIMHomeViewController.h"
#import <Masonry/Masonry.h>
#import <JXCategoryView/JXCategoryView.h>
#import <TUICommonModel.h>
//chat
#import <TUIChatConversationModel.h>
#import <TUIC2CChatViewController.h>
#import <TUIGroupCreateController.h>
//contact
#import "TUIContactSelectController.h"
//group
#import <TUIGroupService.h>
#import <TUIGroupChatViewController.h>

#import "TIMMessageViewController.h"
#import "TIMContactViewController.h"
#import "TIMFriendDynamicsViewController.h"
#import "TIMPopView.h"
#import "TIMPopCell.h"
#import "TUIThemeManager.h"

typedef NS_ENUM(NSUInteger, TIMHomeItem) {
    TIMHomeItemMessage,
    TIMHomeItemContact,
    TIMHomeItemFriendDynamics,
};

NSString *NSStringFromTIMHomeItem(TIMHomeItem item) {
    switch (item) {
        case TIMHomeItemMessage:
            return @"消息";
            break;
        case TIMHomeItemContact:
            return @"联系人";
            break;
        case TIMHomeItemFriendDynamics:
            return @"车与动态";
            break;
    }
}

@interface TIMHomeViewController () <JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, TIMPopViewDelegate>

@property(nonatomic, copy) NSArray<NSString *> *categories;
@property(nonatomic, strong) JXCategoryTitleView *categoryView;
@property(nonatomic, strong) JXCategoryListContainerView *listContainerView;

@end

@implementation TIMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categories = @[
        NSStringFromTIMHomeItem(TIMHomeItemMessage),
        NSStringFromTIMHomeItem(TIMHomeItemContact),
        NSStringFromTIMHomeItem(TIMHomeItemFriendDynamics),
    ];
    [self configureView];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO];
//}

- (void)configureView {
    [self configureCategoryView];
    [self configureaTopRightButton];
}

- (void)configureCategoryView {
    self.categoryView = [[JXCategoryTitleView alloc] init];
    self.categoryView.titles = self.categories;
    self.categoryView.titleSelectedColor = [UIColor tui_colorWithHex:@"#333333"];
    self.categoryView.titleColor = [UIColor tui_colorWithHex:@"#666666"];
    self.categoryView.titleFont = [UIFont systemFontOfSize:14 weight:(UIFontWeightMedium)];
    self.categoryView.titleFont = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    self.categoryView.averageCellSpacingEnabled = NO;
    
    JXCategoryIndicatorLineView *lineIndicatorView = [[JXCategoryIndicatorLineView alloc] init];
    lineIndicatorView.indicatorColor = [UIColor tui_colorWithHex:@"#FEA902"];
    lineIndicatorView.indicatorHeight = 2.0f;
    
    self.categoryView.indicators = @[lineIndicatorView];
    self.categoryView.delegate = self;
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:(JXCategoryListContainerType_ScrollView) delegate:self];
    self.categoryView.listContainer = self.listContainerView;
    
    UIView *container = [UIView new];
    [self.view addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    [container addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.width.equalTo(container);
        make.height.equalTo(@30);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(container.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)configureaTopRightButton {
    UIButton *topRightButton = [[UIButton alloc] init];
//    [topRightButton setTitle:@"more" forState:(UIControlStateNormal)];
//    [topRightButton setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
    [topRightButton setImage:[UIImage imageNamed:@"icon_circle_plus"] forState:(UIControlStateNormal)];
//    [topRightButton alignVerticalImageText];
    [topRightButton addTarget:self action:@selector(topRightButtonOnClicked:event:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.categoryView addSubview:topRightButton];
    [topRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.categoryView);
            make.right.equalTo(self.categoryView).offset(-12);
    }];
}

- (void)topRightButtonOnClicked:(UIButton *)button event:(UIControlEvents)event {
    switch (self.categoryView.selectedIndex) {
        case TIMHomeItemMessage:
        {
            NSMutableArray *menus = [NSMutableArray array];
            TIMPopCellData *friend = [[TIMPopCellData alloc] init];
            friend.image = TUIDemoDynamicImage(@"pop_icon_new_chat_img", [UIImage imageNamed:TUIDemoImagePath(@"new_chat")]);
            friend.title = @"新会话";
            [menus addObject:friend];
            
            TIMPopCellData *group = [[TIMPopCellData alloc] init];
            group.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
            group.title = @"新群聊";
            [menus addObject:group];
            
            CGFloat height = [TIMPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
            CGFloat orginY = StatusBar_Height + NavBar_Height;
            TIMPopView *popView = [[TIMPopView alloc] initWithFrame:CGRectMake(Screen_Width - 155, orginY, 145, height)];
            CGRect frameInNaviView = [self.navigationController.view convertRect:button.frame fromView:button.superview];
            popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
            popView.delegate = self;
            [popView setData:menus];
            [popView showInWindow:self.view.window];
        }
            break;
        case TIMHomeItemContact:
        {
            NSMutableArray *menus = [NSMutableArray array];
            TIMPopCellData *addFriend = [[TIMPopCellData alloc] init];
            addFriend.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
            addFriend.title = @"添加好友";
            [menus addObject:addFriend];
            
            TIMPopCellData *scan = [[TIMPopCellData alloc] init];
            scan.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
            scan.title = @"扫一扫";
            [menus addObject:scan];
            
            TIMPopCellData *myQRCode = [[TIMPopCellData alloc] init];
            myQRCode.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
            myQRCode.title = @"我的二维码";
            [menus addObject:myQRCode];
            
            TIMPopCellData *messageSetting = [[TIMPopCellData alloc] init];
            messageSetting.image = TUIDemoDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIDemoImagePath(@"new_groupchat")]);
            messageSetting.title = @"消息设置";
            [menus addObject:messageSetting];
            
            CGFloat height = [TIMPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
            CGFloat orginY = StatusBar_Height + NavBar_Height;
            TIMPopView *popView = [[TIMPopView alloc] initWithFrame:CGRectMake(Screen_Width - 155, orginY, 145, height)];
            CGRect frameInNaviView = [self.navigationController.view convertRect:button.frame fromView:button.superview];
            popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
            popView.delegate = self;
            [popView setData:menus];
            [popView showInWindow:self.view.window];
        }
            break;
        case TIMHomeItemFriendDynamics:
            break;
        default:
            break;
    }

}

#pragma mark JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
#if DEBUG
    NSLog(@"%s index: %li", __PRETTY_FUNCTION__, (long)index);
#endif
}

#pragma mark JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categories.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    TIMHomeItem item = index;
    switch (item) {
        case TIMHomeItemMessage:
            return [[TIMMessageViewController alloc] init];
            break;
        case TIMHomeItemContact:
            return [[TIMContactViewController alloc] init];
            break;
        case TIMHomeItemFriendDynamics:
            return [[TIMFriendDynamicsViewController alloc] init];
            break;
    }
}

#pragma mark - TIMPopViewDelegate

- (void)popView:(TIMPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    @weakify(self)
    if(index == 0){
        // launch conversation
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = NSLocalizedString(@"ChatsSelectContact", nil);
        vc.maxSelectCount = 1;
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *array) {
            @strongify(self)
            TUIChatConversationModel *data = [[TUIChatConversationModel alloc] init];
            data.userID = array.firstObject.identifier;
            data.title = array.firstObject.title;
            TUIC2CChatViewController *chat = [[TUIC2CChatViewController alloc] init];
            chat.conversationData = data;
            [self.navigationController pushViewController:chat animated:YES];

            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempArray removeObjectAtIndex:tempArray.count-2];
            self.navigationController.viewControllers = tempArray;
        };
        return;
    }
    else {
        // create discuss group
        TUIContactSelectController *vc = [TUIContactSelectController new];
        vc.title = NSLocalizedString(@"ChatsSelectContact", nil);
        [self.navigationController pushViewController:vc animated:YES];
        vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *array) {
            @strongify(self)

            TUIGroupCreateController * groupCreateController = [[TUIGroupCreateController alloc] init];
            groupCreateController.title = @"";
            [[TUIGroupService shareInstance] getGroupNameNormalFormatByContacts:array completion:^(BOOL success, NSString * _Nonnull groupName) {
                V2TIMGroupInfo * createGroupInfo = [[V2TIMGroupInfo alloc] init];
                createGroupInfo.groupID = @"";
                createGroupInfo.groupName = groupName;
                createGroupInfo.groupType = @"Work";
                groupCreateController.createGroupInfo = createGroupInfo;
                groupCreateController.createContactArray = [NSArray arrayWithArray:array];
                [self.navigationController pushViewController:groupCreateController animated:YES];

            }];
            
            groupCreateController.submitCallback = ^(BOOL isSuccess, V2TIMGroupInfo * _Nonnull info) {
                [self jumpToNewChatVCWhenCreatGroupSuccess:isSuccess info:info];
            };
            return;
        };
        return;
    }
}

- (void)jumpToNewChatVCWhenCreatGroupSuccess:(BOOL)isSuccess info:(V2TIMGroupInfo *)info {
    if (!isSuccess) {
        return;
    }
    TUIChatConversationModel *conversationData = [[TUIChatConversationModel alloc] init];
    conversationData.groupID = info.groupID;
    conversationData.title = info.groupName;
    conversationData.groupType = info.groupType;
    
    TUIGroupChatViewController *vc = [[TUIGroupChatViewController alloc] init];
    vc.conversationData = conversationData;
    
    [self.navigationController pushViewController:vc animated:YES];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"TUIGroupCreateController")] ||
            [vc isKindOfClass:NSClassFromString(@"TUIContactSelectController")]) {
            [tempArray removeObject:vc];
        }
    }
    
    self.navigationController.viewControllers = tempArray;
}

@end
