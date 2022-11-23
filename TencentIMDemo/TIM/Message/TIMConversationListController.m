//
//  TIMConversationListController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/23.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMConversationListController.h"
#import "TUIConversationCell.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIConversationListDataProvider.h"
#import "TIMImage.h"

typedef NS_ENUM(NSUInteger, TIMConversationListSectionType) {
    TIMConversationListSectionTypeService,
    TIMConversationListSectionTypeChat,
    TIMConversationListSectionTypeNumber,
};

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TIMConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TUINotificationProtocol, TUIConversationListDataProviderDelegate>

@end

@implementation TIMConversationListController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isEnableSearch = NO;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor tui_colorWithHex:@"#F6F6F9"];
    [self setupViews];
    [self.provider loadNexPageConversations];
}

- (void)setupViews {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = TUIConversationDynamicColor(@"conversation_bg_color", @"#FFFFFF");
    
    UIView *searchBar = nil;
    if (self.isEnableSearch) {
        NSDictionary *searchExtension = [TUICore getExtensionInfo:TUICore_TUIConversationExtension_GetSearchBar param:@{TUICore_TUIConversationExtension_ParentVC : self}];
        if (searchExtension) {
            searchBar = [searchExtension tui_objectForKey:TUICore_TUIConversationExtension_SearchBar asClass:UIView.class];
        }
    }
    //Fix  translucent = NO;
    CGRect rect = self.view.bounds;
    if (![UINavigationBar appearance].isTranslucent && [[[UIDevice currentDevice] systemVersion] doubleValue]<15.0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - TabBar_Height - NavBar_Height );
    }
    _tableView = [[UITableView alloc] initWithFrame:rect];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = TConversationCell_Height;
    _tableView.rowHeight = TConversationCell_Height;
    if (searchBar) {
        [searchBar setFrame: CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        _tableView.tableHeaderView = searchBar;
    }
    
    _tableView.delaysContentTouches = NO;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorColor:TUICoreDynamicColor(@"separator_color", @"#DBDBDB")];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (TUIConversationListDataProvider *)provider {
    if (_provider == nil) {
        _provider = [[TUIConversationListDataProvider alloc] init];
        _provider.delegate = self;
    }
    return _provider;
}

#pragma mark TUIConversationListDataProviderDelegate
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        return [self.delegate getConversationDisplayString:conversation];
    }
    return nil;
}

- (void)insertConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf insertConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    indexPaths = [self changeIndexPathsSectioncTo:TIMConversationListSectionTypeChat from:indexPaths];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    if (self.tableView.isEditing) {
        self.tableView.editing = NO;
    }
    indexPaths = [self changeIndexPathsSectioncTo:TIMConversationListSectionTypeChat from:indexPaths];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteConversationAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf deleteConversationAtIndexPaths:indexPaths];
        });
        return;
    }
    indexPaths = [self changeIndexPathsSectioncTo:TIMConversationListSectionTypeChat from:indexPaths];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadAllConversations {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadAllConversations];
        });
        return;
    }
    [self.tableView reloadData];
}

- (NSArray<NSIndexPath *> *)changeIndexPathsSectioncTo:(NSInteger)section from:(NSArray<NSIndexPath *> *)indexPaths {
    return [[indexPaths.rac_sequence map:^id _Nullable(NSIndexPath *  _Nullable value) {
        return [NSIndexPath indexPathForRow:value.row inSection:TIMConversationListSectionTypeChat];
    }] array];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TIMConversationListSectionTypeNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TIMConversationListSectionType type = section;
    switch (type) {
        case TIMConversationListSectionTypeService:
            return 2;
            break;
        case TIMConversationListSectionTypeChat:
            if (self.dataSourceChanged) {
                self.dataSourceChanged(self.provider.conversationList.count);
            }
            return self.provider.conversationList.count;
            break;
        case TIMConversationListSectionTypeNumber:
            return 0;
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TIMConversationListSectionType type = indexPath.section;
    switch (type) {
        case TIMConversationListSectionTypeService:
            return NO;
            break;
        case TIMConversationListSectionTypeChat:
            return YES;
            break;
        case TIMConversationListSectionTypeNumber:
            return NO;
            break;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIMConversationListSectionType type = indexPath.section;
    switch (type) {
        case TIMConversationListSectionTypeService:
            return @[];
            break;
        case TIMConversationListSectionTypeChat:
        {
            NSMutableArray *rowActions = [NSMutableArray array];
            TUIConversationCellData *cellData = self.provider.conversationList[indexPath.row];
            __weak typeof(self) weakSelf = self;

            UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TUIKitLocalizableString(Delete) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf.provider removeConversation:cellData];
            }];
            deleteAction.backgroundColor = RGB(242, 77, 76);

            UITableViewRowAction *stickyonTopAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:cellData.isOnTop?TUIKitLocalizableString(CancelStickonTop):TUIKitLocalizableString(StickyonTop) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf.provider pinConversation:cellData pin:!cellData.isOnTop];
            }];
            stickyonTopAction.backgroundColor = RGB(242, 147, 64);
            

            UITableViewRowAction *clearHistoryAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TUIKitLocalizableString(ClearHistoryChatMessage) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf.provider clearHistoryMessage:cellData];
            }];
            clearHistoryAction.backgroundColor = RGB(32, 124, 231);
            
            
            UITableViewRowAction *markAsReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:(cellData.isMarkAsUnread||cellData.unreadCount > 0)  ? TUIKitLocalizableString(MarkAsRead) : TUIKitLocalizableString(MarkAsUnRead) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
                    [weakSelf.provider markConversationAsRead:cellData];
                    if (cellData.isLocalConversationFoldList) {
                        [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                    }
                }
                else {
                    [weakSelf.provider markConversationAsUnRead:cellData];
                    if (cellData.isLocalConversationFoldList) {
                        [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                    }
                }
                
            }];
            markAsReadAction.backgroundColor = RGB(20, 122, 255);
                
            
            UITableViewRowAction *markHideAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:TUIKitLocalizableString(MarkHide) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf.provider markConversationHide:cellData];
                if (cellData.isLocalConversationFoldList) {
                    [TUIConversationListDataProvider  cacheConversationFoldListSettings_HideFoldItem:YES];
                }
            }];
            markHideAction.backgroundColor = RGB(242, 147, 64);
            
            //config Actions
            if (cellData.isLocalConversationFoldList) {
                [rowActions addObject:markHideAction];
            }
            else {
                
                [rowActions addObject:deleteAction];

                //        [rowActions addObject:stickyonTopAction];

                //        [rowActions addObject:clearHistoryAction];
                
                [rowActions addObject:markAsReadAction];
                
                [rowActions addObject:markHideAction];
            }
            
            return rowActions;

        }
            break;
        case TIMConversationListSectionTypeNumber:
            return @[];
            break;
    }
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    TIMConversationListSectionType type = indexPath.section;
    switch (type) {
        case TIMConversationListSectionTypeService:
            return nil;
            break;
        case TIMConversationListSectionTypeChat:
        {
            __weak typeof(self) weakSelf = self;
            TUIConversationCellData *cellData = self.provider.conversationList[indexPath.row];
            NSMutableArray *arrayM = [NSMutableArray array];
            
            UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:TUIKitLocalizableString(Delete) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                completionHandler(YES);
                weakSelf.tableView.editing = NO;
                [weakSelf.provider removeConversation:cellData];
            }];
            deleteAction.backgroundColor = RGB(242, 77, 76);
                
            UIContextualAction *stickyonTopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:cellData.isOnTop?TUIKitLocalizableString(CancelStickonTop):TUIKitLocalizableString(StickyonTop) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                completionHandler(YES);
                weakSelf.tableView.editing = NO;
                [weakSelf.provider pinConversation:cellData pin:!cellData.isOnTop];
            }];
            stickyonTopAction.backgroundColor = RGB(242, 147, 64);

            UIContextualAction *clearHistoryAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TUIKitLocalizableString(ClearHistoryChatMessage) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                completionHandler(YES);
                weakSelf.tableView.editing = NO;
                [weakSelf.provider clearHistoryMessage:cellData];
            }];
            clearHistoryAction.backgroundColor = RGB(32, 124, 231);
            
            UIContextualAction *markAsReadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:(cellData.isMarkAsUnread||cellData.unreadCount > 0)  ? TUIKitLocalizableString(MarkAsRead) : TUIKitLocalizableString(MarkAsUnRead) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                if (cellData.isMarkAsUnread||cellData.unreadCount > 0) {
                    [weakSelf.provider markConversationAsRead:cellData];
                    if (cellData.isLocalConversationFoldList) {
                        [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                    }
                }
                else {
                    [weakSelf.provider markConversationAsUnRead:cellData];
                    if (cellData.isLocalConversationFoldList) {
                        [TUIConversationListDataProvider  cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                    }
                }
            }];
            markAsReadAction.backgroundColor = RGB(20, 122, 255);
            
            UIContextualAction *markHideAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TUIKitLocalizableString(MarkHide) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                [weakSelf.provider markConversationHide:cellData];
                if (cellData.isLocalConversationFoldList) {
                    [TUIConversationListDataProvider  cacheConversationFoldListSettings_HideFoldItem:YES];
                }
            }];
            markHideAction.backgroundColor = RGB(242, 147, 64);
            
            //config Actions
            if (cellData.isLocalConversationFoldList) {
                [arrayM addObject:markHideAction];
            }
            else {
                
                [arrayM addObject:deleteAction];

                //        [arrayM addObject:stickyonTopAction];

                //        [arrayM addObject:clearHistoryAction];

                [arrayM addObject:markHideAction];
                
                [arrayM addObject:markAsReadAction];
            }
            


            UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:[NSArray arrayWithArray:arrayM]];
            configuration.performsFirstActionWithFullSwipe = NO;
            return configuration;
        }
            break;
        case TIMConversationListSectionTypeNumber:
            return nil;
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIMConversationListSectionType type = indexPath.section;
    switch (type) {
        case TIMConversationListSectionTypeService:
        {
            if (indexPath.row == 0) {
                TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
                TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
                data.title = @"title";
                data.subTitle = [[NSMutableAttributedString alloc] initWithString:@"🍎subTitle attributedString"];
                data.avatarImage = [TIMImage imageNamed:@"icon_serviece_notification"];
                [cell fillWithData:data];
                return cell;
            } else {
                TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
                TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
                data.title = @"title";
                data.subTitle = [[NSMutableAttributedString alloc] initWithString:@"🍎subTitle attributedString"];
                data.avatarImage = [TIMImage imageNamed:@"avatar_service_store"];
                [cell fillWithData:data];
                return cell;
            }
        }
            break;
        case TIMConversationListSectionTypeChat:
        {
            TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
            TUIConversationCellData *data = [self.provider.conversationList objectAtIndex:indexPath.row];
            [cell fillWithData:data];
            return cell;
        }
            break;
        case TIMConversationListSectionTypeNumber:
            return [[UITableViewCell alloc] init];
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TIMConversationListSectionType type = indexPath.section;
    switch (type) {
        case TIMConversationListSectionTypeService:
            break;
        case TIMConversationListSectionTypeChat:
        {
            TUIConversationCellData *data = [self.provider.conversationList objectAtIndex:indexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
                [self.delegate conversationListController:self didSelectConversation:data];
            }
        }
            break;
        case TIMConversationListSectionTypeNumber:
            break;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //通过开启或关闭这个开关，控制最后一行分割线的长度
    //Turn on or off the length of the last line of dividers by controlling this switch
    BOOL needLastLineFromZeroToMax = NO;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (needLastLineFromZeroToMax && indexPath.row == (self.provider.conversationList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.provider loadNexPageConversations];
}

@end
