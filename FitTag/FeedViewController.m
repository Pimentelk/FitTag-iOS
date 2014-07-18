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
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
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
