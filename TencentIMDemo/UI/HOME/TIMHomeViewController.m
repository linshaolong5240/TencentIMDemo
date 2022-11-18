//
//  TIMHomeViewController.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/17.
//

#import "TIMHomeViewController.h"
#import <Masonry/Masonry.h>
#import <JXCategoryView/JXCategoryView.h>

#import "TIMContactViewController.h"
#import "TIMMessageViewController.h"
#import "TIMFriendDynamicsViewController.h"

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

@interface TIMHomeViewController () <JXCategoryViewDelegate, JXCategoryListContainerViewDelegate>

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

- (void)configureView {
    [self configureCategoryView];
}

- (void)configureCategoryView {
    self.categoryView = [[JXCategoryTitleView alloc] init];
    self.categoryView.titles = self.categories;
    self.categoryView.averageCellSpacingEnabled = NO;
    
    JXCategoryIndicatorLineView *lineIndicatorView = [[JXCategoryIndicatorLineView alloc] init];
    lineIndicatorView.indicatorColor = UIColor.orangeColor;
    lineIndicatorView.indicatorHeight = 2.0f;
    
    self.categoryView.indicators = @[lineIndicatorView];
    self.categoryView.delegate = self;
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:(JXCategoryListContainerType_ScrollView) delegate:self];
    self.categoryView.listContainer = self.listContainerView;
    
    UIView *container = [UIView new];
    [self.view addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@56);
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

@end
