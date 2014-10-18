//
//  NotificationsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTActivityFeedViewController.h"
#import "FTSettingsActionSheetDelegate.h"
#import "FTActivityCell.h"
//#import "FTAccountViewController.h"
#import "FTUserProfileCollectionViewController.h"
#import "FTPhotoDetailsViewController.h"
#import "FTBaseTextCell.h"
#import "FTLoadMoreCell.h"
#import "FTSettingsButtonItem.h"
#import "FTFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "FTCamViewController.h"
#import "FTPostDetailsViewController.h"

@interface FTActivityFeedViewController ()

@property (nonatomic, strong) FTSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTActivityFeedViewController

@synthesize settingsActionSheetDelegate;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"%@::viewWillDisappear",VIEWCONTROLLER_ACTIVITY);
    // Get the classname of the next view controller
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack-1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqual:VIEWCONTROLLER_CAM]){
        [self.navigationController setToolbarHidden:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    NSLog(@"%@::preferredStatusBarStyle",VIEWCONTROLLER_ACTIVITY);
    return UIStatusBarStyleLightContent;
}

- (void)didTapLoadCamera:(id)sender{
    FTCamViewController *cameraViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@::tableView:heightForRowAtIndexPath:",VIEWCONTROLLER_ACTIVITY);
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [FTActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kFTActivityTypeKey]];
        
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
            //FTPhotoDetailsViewController *detailViewController = [[FTPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kFTActivityPostKey]];
            //[self.navigationController pushViewController:detailViewController animated:YES];
            FTPostDetailsViewController *postDetailViewController = [[FTPostDetailsViewController alloc] initWithPost:[activity objectForKey:kFTActivityPostKey] AndType:nil];
            [self.navigationController pushViewController:postDetailViewController animated:YES];
        } else if ([activity objectForKey:kFTActivityFromUserKey]) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setItemSize:CGSizeMake(105.5,105)];
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
            [flowLayout setMinimumInteritemSpacing:0];
            [flowLayout setMinimumLineSpacing:0];
            [flowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [flowLayout setHeaderReferenceSize:CGSizeMake(320,335)];
            
            FTUserProfileCollectionViewController *profileViewController = [[FTUserProfileCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
            [profileViewController setUser:[PFUser currentUser]];
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
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kFTActivityToUserKey equalTo:[PFUser currentUser]];
    //[query whereKey:kFTActivityFromUserKey notEqualTo:[PFUser currentUser]];
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

- (void)objectsDidLoad:(NSError *)error {
    NSLog(@"FTActivityFeedViewController::objectsDidLoad");
    [super objectsDidLoad:error];
    NSLog(@"error: %@",error);
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kFTUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSLog(@"self.objects.count: %lu",(unsigned long)self.objects.count);
    NSLog(@"hasCachedResult: %d",[[self queryForTable] hasCachedResult]);
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        NSLog(@"No cached results");
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
    
    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
    
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
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

#pragma mark - FTActivityCellDelegate Methods

- (void)cell:(FTActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    NSLog(@"FTActivityFeedViewController::didTapActivityButton:");
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kFTActivityPostKey];
    
    // Push single photo view controller
    FTPhotoDetailsViewController *photoViewController = [[FTPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(FTBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    NSLog(@"FTActivityFeedViewController::didTapUserButton:");
    // Push account view controller
    //FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    //[accountViewController setUser:user];
    //[self.navigationController pushViewController:accountViewController animated:YES];
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
    } else {
        return nil;
    }
}

#pragma mark - ()
/*
- (void)settingsButtonAction:(id)sender {
    NSLog(@"FTActivityFeedViewController::settingsButtonAction:");
    settingsActionSheetDelegate = [[FTSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"My Profile", nil), NSLocalizedString(@"Find Friends", nil), NSLocalizedString(@"Log Out", nil), nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/
- (void)inviteFriendsButtonAction:(id)sender {
    NSLog(@"FTActivityFeedViewController::inviteFriendsButtonAction:");
    FTFindFriendsViewController *detailViewController = [[FTFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}

@end
