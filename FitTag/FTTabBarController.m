//
//  PAPTabBarController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "FTTabBarController.h"
#import "FTSettingsViewController.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2

@interface FTTabBarController ()
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic, strong) FTSettingsViewController *settingsViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@end

@implementation FTTabBarController
@synthesize navController;

#pragma mark - UIViewController

- (void)viewDidLoad {
    //NSLog(@"%@::viewDidLoad",VIEWCONTROLLER_TABBAR);
    [super viewDidLoad];
    
    self.tabBar.tintColor = FT_RED;
    self.tabBar.barTintColor = FT_RED;
    self.tabBar.hidden = YES;
    
    [self.view setFrame:CGRectZero];
    
    //self.navController = [[UINavigationController alloc] init];
    //[FTUtility addBottomDropShadowToNavigationBarForNavigationController:self.navController];
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    //NSLog(@"%@::setViewControllers:animated:",VIEWCONTROLLER_TABBAR);
    [super setViewControllers:viewControllers animated:animated];
}

@end
