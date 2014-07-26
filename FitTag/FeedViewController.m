//
//  FeedViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FeedViewController.h"
#import "FindFriendsFlowLayout.h"
#import "FindFriendsViewController.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    UIBarButtonItem *fitTag = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"] style:UIBarButtonItemStylePlain target:self action:@selector(fitTag)];
    
    [fitTag setTintColor:[UIColor whiteColor]];
    [addFriends setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:fitTag];
    [self.navigationItem setLeftBarButtonItem:addFriends];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}

- (PFQuery *)queryForTable
{
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    // Query for the friends the current user is following
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    
    // Using the activities from the query above, we find all of the photos taken by
    // the friends the current user is following
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kFTPhotoUserKey matchesKey:kFTActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyExists:kFTPhotoPictureKey];
    
    // We create a second query for the current user's photos
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kFTPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kFTPhotoPictureKey];
    
    // We create a final compound query that will find all of the photos that were
    // taken by the user's friends or by the user
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
    [query includeKey:kFTPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    /*
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    */
    return query;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar

- (void)fitTag
{
    NSLog(@"FitTagFeedViewController::fitTag");
}

- (void)addFriends
{
    NSLog(@"FitTagFeedViewController::addFriends");
    // Layout param
    FindFriendsFlowLayout *layoutFlow = [[FindFriendsFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(320,42)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(320,32)];
     
    // Show the interests
    FindFriendsViewController *rootViewController = [[FindFriendsViewController alloc] initWithCollectionViewLayout:layoutFlow];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

#pragma mark - Tool Bar

-(void)viewNotifications
{
    NSLog(@"FitTagFeedViewController::viewNotifications");
}

-(void)viewSearch
{
    NSLog(@"FitTagFeedViewController::viewSearch");
}

-(void)viewMyProfile
{
    NSLog(@"FitTagFeedViewController::viewMyProfile");
}

-(void)viewOffers
{
    NSLog(@"FitTagFeedViewController::viewOffers");
}

@end
