//
//  TIMTabbarController.m
//  TencentIMDemo
//
//  Created by Saruon on 2022/11/22.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMTabbarController.h"
#import "TIMNavigationController.h"
#import "TIMHomeViewController.h"

@interface TIMTabbarController ()

@end

@implementation TIMTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureTabBar];
}

- (void)configureTabBar {
    
    if (@available(iOS 13.0, *)) {
        UIViewController *vc0 = [self makeTabBarViewController:[UIViewController new] title:@"vc1" image:[UIImage systemImageNamed:@"circle"] selectedImage:[UIImage systemImageNamed:@"circle.fill"]];
        UIViewController *vc1 = [self makeTabBarViewController:[TIMHomeViewController new] title:@"TIM" image:[UIImage systemImageNamed:@"message"] selectedImage:[UIImage systemImageNamed:@"message.fill"]];
        UIViewController *vc2 = [self makeTabBarViewController:[UIViewController new] title:@"vc3" image:[UIImage systemImageNamed:@"square"] selectedImage:[UIImage systemImageNamed:@"square.fill"]];
        
        self.viewControllers = @[vc0, vc1, vc2];
    } else {
        // Fallback on earlier versions
    }
}

- (UIViewController *)makeTabBarViewController:(UIViewController *)viewController title:(nullable NSString *)title image:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage {
    UIViewController *vc = [[TIMNavigationController alloc] initWithRootViewController:viewController];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    vc.tabBarItem = tabBarItem;
    return vc;
}

@end
