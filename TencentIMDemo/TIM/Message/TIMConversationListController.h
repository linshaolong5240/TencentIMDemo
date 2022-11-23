//
//  TIMConversationListController.h
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/23.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import <TUIConversationListController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIMConversationListControllerListener <NSObject>
@optional

/**
 *  在会话列表中，获取会话展示信息时候回调。
 *  In the conversation list, the callback to get the session display information.
 */
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

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
- (void)conversationListController:(UIViewController *)conversationController didSelectConversation:(TUIConversationCellData *)conversation;

- (void)searchController:(UIViewController *)searchVC
                 withKey:(NSString *)searchKey
           didSelectType:(TUISearchType)searchType
                    item:(NSObject *)searchItem
    conversationCellData:(TUIConversationCellData *)conversationCellData;
@end
/**
 * 【模块名称】会话列表界面组件（TUIConversationListController）
 *
 * 【功能说明】负责按消息的接收顺序展示各个会话，同时响应用户的操作，为用户提供多会话的管理功能。
 *  会话列表所展示的会话信息包括：
 *  1、头像信息（用户头像/群头像）
 *  2、会话标题（用户昵称/群名称）
 *  3、会话消息概览（展示最新的一条的消息内容）
 *  4、未读消息数（若有未读消息的话）
 *  5、会话时间（最新消息的收到/发出时间）
 *
 *
 * 【Module name】 message list interface component (TUIConversationListController)
 *
 * 【Function description】 It is responsible for displaying each conversation in the order in which the messages are received, and responding to the user's operation, providing users with multi-session management functions.
 *  The conversation information displayed in the conversation list includes:
 *  1. Avatar information (user avatar/group avatar)
 *  2. Conversation title (user nickname/group name)
 *  3. Conversation message overview (display the latest message content)
 *  4. The number of unread messages (if there are unread messages)
 *  5. Conversation time (receive/send time of the latest message)
 */
@interface TIMConversationListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<TIMConversationListControllerListener> delegate;

@property (nonatomic, strong) TUIConversationListDataProvider *provider;

/**
 *  是否展示搜索框，如果集成了 TUICalling 组件，默认会展示
 *  An identifier that identifies whether to display the search box, If the TUICalling component is integrated, it will be displayed by default
 */
@property (nonatomic) BOOL isEnableSearch;

@property (nonatomic,copy) void(^dataSourceChanged)(NSInteger count);

@end

NS_ASSUME_NONNULL_END
