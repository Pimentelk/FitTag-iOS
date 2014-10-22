//
//  PAPTabBarController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "FTTabBarController.h"

@interface FTTabBarController ()
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation FTTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    NSLog(@"%@::viewDidLoad",VIEWCONTROLLER_TABBAR);
    [super viewDidLoad];
    
    //[[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    //[[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"BackgroundTabBarItemSelected.png"]];
    
    self.tabBar.tintColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                            green:FT_RED_COLOR_GREEN
                                             blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    // iOS 7 style
    self.tabBar.tintColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                            green:FT_RED_COLOR_GREEN
                                             blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    self.navController = [[UINavigationController alloc] init];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:self.navController];
}

#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    //NSLog(@"%@::setViewControllers:animated:",VIEWCONTROLLER_TABBAR);
    [super setViewControllers:viewControllers animated:animated];
}

@end
