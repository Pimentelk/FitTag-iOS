//
//  FeedViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFeedViewController.h"
#import "FindFriendsFlowLayout.h"
#import "FTFindFriendsViewController.h"
#import "FTActivityFeedViewController.h"
#import "FTNavigationBar.h"
#import "FTSettingsActionSheetDelegate.h"
#import "ImageCollectionViewController.h"
#import "ImageCustomNavigationBar.h"
#import "FTCameraToolBar.h"

@interface FTFeedViewController ()
@property (nonatomic, strong) FTSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTFeedViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Toolbar & Navigationbar Setup
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationItem setTitle: @"FEED"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.toolbar setDelegate:self];
    
    UIBarButtonItem *addFriends = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_contacts"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriends)];
    UIBarButtonItem *fitTagPost = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"] style:UIBarButtonItemStylePlain target:self action:@selector(fitTagPost:)];
    [fitTagPost setTintColor:[UIColor whiteColor]];
    [addFriends setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:fitTagPost];
    [self.navigationItem setLeftBarButtonItem:addFriends];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
}

#pragma mark - Navigation Bar

- (void)fitTagPost:(id)sender
{
    
    NSLog(@"FTFeedViewController::fitTagPost");
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(104,104)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    ImageCollectionViewController *rootViewController = [[ImageCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithNavigationBarClass:[ImageCustomNavigationBar class]
                                                                                          toolbarClass:[FTCameraToolBar class]];
    
    [naviController setViewControllers:@[rootViewController] animated:NO];
    
    [self presentViewController:naviController animated:YES completion:NULL];
    
    rootViewController.onCompletion = ^(id result){
        [naviController dismissViewControllerAnimated:YES completion:NULL];
        NSLog(@"Image selected result: %@ ", result);
    };
}

- (void)addFriends
{
    NSLog(@"FTFeedViewController::addFriends");
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

#pragma mark - Tool Bar
-(void)viewNotifications
{
    // Show Activity Feed
    FTActivityFeedViewController *rootViewController = [[FTActivityFeedViewController alloc] init];
    UINavigationController *naviController = [[UINavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class]
                                                                                          toolbarClass:[FTToolBar class]];
    
    [naviController setViewControllers:@[rootViewController] animated:NO];
    
    [self presentViewController:naviController animated:YES completion:NULL];
}

-(void)viewSearch
{
    NSLog(@"FTFeedViewController::viewSearch");
}

-(void)viewMyProfile
{
    NSLog(@"FTFeedViewController::viewMyProfile");
}

-(void)viewOffers
{
    NSLog(@"FTFeedViewController::viewOffers");
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


@end
