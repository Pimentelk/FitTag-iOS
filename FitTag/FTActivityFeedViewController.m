//
//  NotificationsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTActivityFeedViewController.h"
#import "FTActivityCell.h"
#import "FTUserProfileViewController.h"
#import "FTBaseTextCell.h"
#import "FTLoadMoreCell.h"
#import "FTPostDetailsViewController.h"
#import "FTFollowFriendsViewController.h"

@interface FTActivityFeedViewController ()

@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTActivityFeedViewController

@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        NSLog(@"%@::initWithStyle:",VIEWCONTROLLER_ACTIVITY);
        
        // The className to query on
        self.parseClassName = kFTActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    NSLog(@"%@::viewDidLoad",VIEWCONTROLLER_ACTIVITY);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:NAVIGATION_TITLE_NOTIFICATIONS];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kFTUserDefaultsActivityFeedViewControllerLastRefreshKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_ACTIVITY];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    NSLog(@"%@::preferredStatusBarStyle",VIEWCONTROLLER_ACTIVITY);
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@::tableView:heightForRowAtIndexPath:",VIEWCONTROLLER_ACTIVITY);
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        NSString *activityString = nil;
        NSString *currentUserDisplayName = [[PFUser currentUser] objectForKey:kFTUserDisplayNameKey];
        if (currentUserDisplayName) {
            if ([object objectForKey:kFTActivityMentionKey] && [[object objectForKey:kFTActivityMentionKey] containsObject:currentUserDisplayName]) {
                activityString = [FTActivityFeedViewController stringForActivityType:kFTActivityTypeMention];
            }
        } else {
            activityString = [FTActivityFeedViewController stringForActivityType:(NSString *)[object objectForKey:kFTActivityTypeKey]];
        }
        
        PFUser *user = (PFUser*)[object objectForKey:kFTActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kFTUserDisplayNameKey] && [[user objectForKey:kFTUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kFTUserDisplayNameKey];
        }
        
        return [FTActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@::tableView:didSelectRowAtIndexPath:",VIEWCONTROLLER_ACTIVITY);
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kFTActivityPostKey]) {
            FTPostDetailsViewController *postDetailViewController = [[FTPostDetailsViewController alloc] initWithPost:[activity objectForKey:kFTActivityPostKey] AndType:nil];
            [self.navigationController pushViewController:postDetailViewController animated:YES];
        } else if ([activity objectForKey:kFTActivityFromUserKey]) {
            // Push user profile
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setItemSize:CGSizeMake(105.5,105)];
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
            [flowLayout setMinimumInteritemSpacing:0];
            [flowLayout setMinimumLineSpacing:0];
            [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
            
            // Override the back idnicator
            UIBarButtonItem *dismissProfileButton = [[UIBarButtonItem alloc] init];
            [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
            [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
            [dismissProfileButton setTarget:self];
            [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
            [dismissProfileButton setTintColor:[UIColor whiteColor]];
            
            FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
            [profileViewController setUser:[activity objectForKey:kFTActivityFromUserKey]];
            [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (PFQuery *)queryForTable {
    //NSLog(@"FTActivityFeedViewController::queryForTable");
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:1000];
        return query;
    }
    
    NSString *displayName = [[PFUser currentUser] objectForKey:kFTUserDisplayNameKey];
    
    if (!displayName) {
        NSLog(@"no displayname..");
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query whereKey:kFTActivityToUserKey equalTo:[PFUser currentUser]];
        [query whereKey:kFTActivityFromUserKey notEqualTo:[PFUser currentUser]];
        [query whereKeyExists:kFTActivityFromUserKey];
        [query includeKey:kFTActivityFromUserKey];
        [query includeKey:kFTActivityPostKey];
        [query orderByDescending:@"createdAt"];
        [query setCachePolicy:kPFCachePolicyNetworkOnly];
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        //
        // If there is no network connection, we will hit the cache first.
        if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
            [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        }
        return query;
    }
    
    //NSLog(@"displayname..");
    PFQuery *queryMentions = [PFQuery queryWithClassName:self.parseClassName];
    [queryMentions whereKey:kFTActivityMentionKey equalTo:displayName];
    [queryMentions whereKey:kFTActivityToUserKey equalTo:[PFUser currentUser]];
    [queryMentions whereKey:kFTActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [queryMentions whereKeyExists:kFTActivityMentionKey];
    [queryMentions setCachePolicy:kPFCachePolicyNetworkOnly];
    
    PFQuery *queryActivity = [PFQuery queryWithClassName:self.parseClassName];
    [queryActivity whereKey:kFTActivityToUserKey equalTo:[PFUser currentUser]];
    [queryActivity whereKey:kFTActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [queryActivity whereKeyExists:kFTActivityFromUserKey];
    [queryMentions setCachePolicy:kPFCachePolicyNetworkOnly];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[ queryMentions, queryActivity ]];
    [query includeKey:kFTActivityFromUserKey];
    [query includeKey:kFTActivityPostKey];
    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    NSLog(@"FTActivityFeedViewController::objectsDidLoad");
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kFTUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        NSLog(@"Cached results");
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";
    //NSLog(@"FTActivityFeedViewController::tableView:cellForRowAtIndexPath:object:");
    FTActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FTActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    [cell setActivity:object];
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    NSLog(@"FTActivityFeedViewController::tableView:cellForNextPageAtIndexPath:");
    FTLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[FTLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

#pragma mark - FTActivityCellDelegate Methods

- (void)cell:(FTActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    NSLog(@"%@::didTapActivityButton:",VIEWCONTROLLER_ACTIVITY);
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kFTActivityPostKey];
    FTPostDetailsViewController *postViewController = [[FTPostDetailsViewController alloc] initWithPost:photo AndType:kFTPostTypeImage];
    [self.navigationController pushViewController:postViewController animated:YES];
}

- (void)cell:(FTBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    NSLog(@"%@::didTapUserButton:",VIEWCONTROLLER_ACTIVITY);
    // Push user profile
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
    
    // Override the back idnicator
    UIBarButtonItem *dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
    [dismissProfileButton setTintColor:[UIColor whiteColor]];
    
    FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setUser:[PFUser currentUser]];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark - FTActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kFTActivityTypeLike]) {
        return NSLocalizedString(@"liked your post", nil);
    } else if ([activityType isEqualToString:kFTActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kFTActivityTypeComment]) {
        return NSLocalizedString(@"commented on your post", nil);
    } else if ([activityType isEqualToString:kFTActivityTypeJoined]) {
        return NSLocalizedString(@"joined #FitTag", nil);
    } else if ([activityType isEqualToString:kFTActivityTypeMention]) {
        return NSLocalizedString(@"mentioned you", nil);
    } else if ([activityType isEqualToString:kFTActivityTypeOffer]) {
        return NSLocalizedString(@"posted a new reward", nil);
    } else {
        return nil;
    }
}

#pragma mark - ()

- (void)followFriendsButtonAction:(id)sender {
    NSLog(@"FTActivityFeedViewController::followFriendsButtonAction:");
    FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] init];
    [self.navigationController pushViewController:followFriendsViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
