//
//  TIMBaseChatViewController.h
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/19.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMBaseViewController.h"

@class TUIChatConversationModel;

NS_ASSUME_NONNULL_BEGIN

@interface TIMBaseChatViewController : TIMBaseViewController

- (void)setConversation:(TUIChatConversationModel *)conversationData;

@end

NS_ASSUME_NONNULL_END
