//
//  FTFeedViewController
//  FitTag
//
//  Created by Kevin Pimentel on 8/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFeedViewController.h"
#import "MBProgressHUD.h"
#import "ImageCustomNavigationBar.h"
#import "FTFindFriendsViewController.h"

#define IMAGE_WIDTH 253.0f
#define IMAGE_HEIGHT 173.0f
#define IMAGE_X 33.0f
#define IMAGE_Y 96.0f

#define ANIMATION_DURATION 0.200f

@interface FTFeedViewController ()
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTFeedViewController
@synthesize firstLaunch;
@synthesize blankTimelineView;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:NAVIGATION_TITLE_FEED];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( IMAGE_X, IMAGE_Y, IMAGE_WIDTH, IMAGE_HEIGHT);
    [button setBackgroundImage:[UIImage imageNamed:IMAGE_TIMELINE_BLANK] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
    
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
        
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
        
    } else {
        
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}

#pragma mark - ()

- (void)inviteFriendsButtonAction:(id)sender {
    FTFindFriendsViewController *detailViewController = [[FTFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end

