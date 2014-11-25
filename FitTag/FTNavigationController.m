//
//  FitTagNavigationBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTNavigationController.h"
#import "FTCamViewController.h"
#import "FTFollowFriendsViewController.h"

@implementation FTNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    //NSLog(@"%@::initWithRootViewController:",VIEWCONTROLLER_NAVIGATION);
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // UIBarbutton items
        UIBarButtonItem *addFriendsButtonItem = [[UIBarButtonItem alloc] init];
        [addFriendsButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_ADD_CONTACTS]];
        [addFriendsButtonItem setStyle:UIBarButtonItemStylePlain];
        [addFriendsButtonItem setTarget:self];
        [addFriendsButtonItem setAction:@selector(didTapAddFriendsButtonAction:)];
        [addFriendsButtonItem setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.leftBarButtonItem = addFriendsButtonItem;
        
        // Initialization code
        UIBarButtonItem *loadCameraButton = [[UIBarButtonItem alloc] init];
        [loadCameraButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_CAMERA]];
        [loadCameraButton setStyle:UIBarButtonItemStylePlain];
        [loadCameraButton setTarget:self];
        [loadCameraButton setAction:@selector(didTapLoadCameraButtonAction:)];
        [loadCameraButton setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.rightBarButtonItem = loadCameraButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    //NSLog(@"%@::viewDidLoad:",VIEWCONTROLLER_NAVIGATION);
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    self.navigationBar.barTintColor = [UIColor colorWithRed:234.0f/255.0f
                                                      green:37.0f/255.0f
                                                       blue:37.0f/255.0f
                                                      alpha:1.0f];
}

#pragma mark - ()

- (void)didTapAddFriendsButtonAction:(UIButton *)button {
    
    // Show the interests
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    followFriendsViewController.followUserQueryType = FTFollowUserQueryTypeDefault;
    [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ followFriendsViewController ] animated:NO];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didTapLoadCameraButtonAction:(UIButton *)button {
    
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ camViewController ] animated:NO];
    
    [self presentViewController:navController animated:YES completion:^(){
        [self.tabBarController setSelectedIndex:TAB_FEED];
    }];
}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
