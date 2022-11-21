//
//  TIMMessageViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/18.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMMessageViewController.h"
#import <TUIConversation.h>
#import <TUIChat.h>
#import "TIMC2CChatViewController.h"
#import "TIMGroupChatViewController.h"
#import "TUIFoldListViewController.h"

@interface TIMMessageViewController () <TUIConversationListControllerListener>

@end

@implementation TIMMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TUIConversationListController *conversationController = [[TUIConversationListController alloc] init];
    conversationController.isEnableSearch = NO;
    conversationController.delegate = self;
    
    [self addChildViewController:conversationController];
    [self.view addSubview:conversationController.view];
}

- (TUIBaseChatViewController *)getChatViewController:(TUIChatConversationModel *)model {
    TUIBaseChatViewController *chat = nil;
    if (model.userID.length > 0) {
        chat = [[TUIC2CChatViewController alloc] init];
    } else if (model.groupID.length > 0) {
        chat = [[TUIGroupChatViewController alloc] init];
    }
    chat.conversationData = model;
    return chat;
}

//- (TIMBaseChatViewController *)getChatViewController:(TUIChatConversationModel *)model {
//    TIMBaseChatViewController *chat = nil;
//    if (model.userID.length > 0) {
//        chat = [[TIMC2CChatViewController alloc] init];
//    } else if (model.groupID.length > 0) {
//        chat = [[TIMGroupChatViewController alloc] init];
//    }
//    [chat setConversation:model];
//    return chat;
//}

- (TUIChatConversationModel *)getConversationModel:(TUIConversationCellData *)data {
    TUIChatConversationModel *model = [[TUIChatConversationModel alloc] init];
    model.conversationID = data.conversationID;
    model.userID = data.userID;
    model.groupType = data.groupType;
    model.groupID = data.groupID;
    model.userID = data.userID;
    model.title = data.title;
    model.faceUrl = data.faceUrl;
    model.avatarImage = data.avatarImage;
    model.draftText = data.draftText;
    model.atMsgSeqs = data.atMsgSeqs;
    return model;
}

#pragma mark - TUIConversationListControllerListener

/**
 *  在会话列表中，获取会话展示信息时候回调。
 *  In the conversation list, the callback to get the session display information.
 */
//- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
//    return @"test";
//}

/**
 *  在会话列表中，点击了具体某一会话后的回调。
 *  您可以通过该回调响应用户的点击操作，跳转到该会话对应的聊天界面。
 *
 *  @param conversationController 委托者，当前所在的消息列表。
 *  @param conversation 被选中的会话单元
 *
 *  The callback for clicking the conversation in the conversation list
 *  You can use this callback to respond to the user's click operation and jump to the chat interface corresponding to the session.
 */
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation {
    if (conversation.isLocalConversationFoldList) {

        [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
        
        TUIFoldListViewController *foldVC = [[TUIFoldListViewController alloc] init];
        [self.navigationController pushViewController:foldVC animated:YES];

        foldVC.dismissCallback = ^(NSMutableAttributedString * _Nonnull foldStr, NSArray * _Nonnull sortArr , NSArray * _Nonnull needRemoveFromCacheMapArray) {
            conversation.foldSubTitle  = foldStr;
            conversation.subTitle = conversation.foldSubTitle;
            conversation.isMarkAsUnread = NO;
        
            if (sortArr.count <= 0 ) {
                conversation.orderKey = 0;
                if ([conversationController.provider.conversationList  containsObject:conversation]) {
                    [conversationController.provider hideConversation:conversation];
                }
            }
            
            for (NSString * removeId in needRemoveFromCacheMapArray) {
                if ([conversationController.provider.markFoldMap objectForKey:removeId] ) {
                    [conversationController.provider.markFoldMap removeObjectForKey:removeId];
                }
            }
            
            [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
            [[(TUIConversationListController *)conversationController tableView] reloadData];
        };
        return;
    }
    TIMBaseChatViewController *chatVc = [self getChatViewController:[self getConversationModel:conversation]];
    [self.navigationController pushViewController:chatVc animated:YES];
}

@end
