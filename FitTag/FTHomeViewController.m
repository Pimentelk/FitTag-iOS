//
//  FTHomeViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTHomeViewController.h"
#import "FTSettingsActionSheetDelegate.h"
#import "FTSettingsButtonItem.h"
#import "FTFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "ImageCustomNavigationBar.h"
#import "FindFriendsFlowLayout.h"
#import "FTActivityFeedViewController.h"
#import "FTNavigationBar.h"
#import "FTToolBar.h"
#import "FTCamViewController.h"
#import "FTRewardsCollectionViewController.h"
#import "FTSearchViewController.h"
#import "FTAccountViewController.h"

@interface FTHomeViewController ()
@property (nonatomic, strong) FTSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Toolbar & Navigationbar Setup
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationItem setTitle: @"FEED"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.toolbar setDelegate:self];
    
    UIBarButtonItem *addFriends = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_contacts"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriends:)];
    UIBarButtonItem *loadCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"] style:UIBarButtonItemStylePlain target:self action:@selector(loadCamera:)];
    
    [loadCamera setTintColor:[UIColor whiteColor]];
    [addFriends setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setRightBarButtonItem:loadCamera];
    [self.navigationItem setLeftBarButtonItem:addFriends];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    // Get the classname of the next view controller
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack-1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqual: @"FTCamViewController"]){
        [self.navigationController setToolbarHidden:YES];
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
    
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
        
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}


#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[FTSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)inviteFriendsButtonAction:(id)sender {
    FTFindFriendsViewController *detailViewController = [[FTFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Navigation Bar

- (void)loadCamera:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:camViewController animated:YES];
}

- (void)addFriends:(id)sender{
    // Layout param
    FindFriendsFlowLayout *layoutFlow = [[FindFriendsFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(320,42)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(320,32)];
    
    // Show the interests
    FTFindFriendsViewController *detailViewController = [[FTFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Toolbar

-(void)viewNotifications:(id)sender {
    NSLog(@"viewNotifications");
    FTActivityFeedViewController *activityFeedViewController = [[FTActivityFeedViewController alloc] init];
    [self.navigationController pushViewController:activityFeedViewController animated:YES];
}

-(void)viewSearch:(id)sender {
    NSLog(@"viewSearch");
    FTSearchViewController *searchViewController = [[FTSearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

-(void)viewMyProfile:(id)sender {
    NSLog(@"viewMyProfile");
    FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:[PFUser currentUser]];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

-(void)viewOffers:(id)sender {
    NSLog(@"viewOffers");
    // Layout param
    FindFriendsFlowLayout *layoutFlow = [[FindFriendsFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(158,185)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(320,160)];
    
    FTRewardsCollectionViewController *rewardsViewController = [[FTRewardsCollectionViewController alloc] initWithCollectionViewLayout:layoutFlow];
    [self.navigationController pushViewController:rewardsViewController animated:YES];
}
@end

