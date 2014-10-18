//
//  FitTagNavigationBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTNavigationController.h"
#import "FTCamViewController.h"

#define VIEWCONTROLLER_NAVIGATION @"FTNavigationController"

@implementation FTNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    NSLog(@"%@::initWithRootViewController:",VIEWCONTROLLER_NAVIGATION);
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Initialization code
        UIBarButtonItem *loadCameraButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_CAMERA]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapLoadCameraButtonAction:)];
        [loadCameraButton setTintColor:[UIColor whiteColor]];
        rootViewController.navigationItem.rightBarButtonItem = loadCameraButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    NSLog(@"%@::viewDidLoad:",VIEWCONTROLLER_NAVIGATION);
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    self.navigationBar.barTintColor = [UIColor colorWithRed:234.0f/255.0f
                                                      green:37.0f/255.0f
                                                       blue:37.0f/255.0f
                                                      alpha:1.0f];
}

- (void)didTapLoadCameraButtonAction:(UIButton *)button {
    // Map Home View
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[camViewController] animated:NO];
    [self presentViewController:navController animated:YES completion:^(){
        [self.tabBarController setSelectedIndex:2];
    }];
}
@end
