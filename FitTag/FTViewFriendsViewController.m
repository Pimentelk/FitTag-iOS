//
//  FTViewFriendsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTViewFriendsViewController.h"
#import "FTUserProfileViewController.h"

#define DATACELL_IDENTIFIER @"DataCell"
#define TABLE_VIEW_HEIGHT 80

@interface FTViewFriendsViewController()

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) FTUserProfileViewController *profileViewController;
@property (nonatomic, strong) UIBarButtonItem *backIndicator;
@end

@implementation FTViewFriendsViewController
@synthesize flowLayout;
@synthesize profileViewController;
@synthesize backIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
    }
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // Set background image
    [self.tableView setBackgroundColor:FT_GRAY];
    [self.tableView setDelegate:self];
    [self.tableView.tableHeaderView setHidden:NO];
    
    // Fittag navigationbar color
    self.navigationController.navigationBar.barTintColor = FT_RED;
    
    // backbutton
    backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INVITE];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - ()

- (void)queryForFollowing {
    
    self.objects = nil;
    [self.tableView reloadData];
    
    // List of all users being followed by current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:self.user];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [followingActivitiesQuery setLimit:1000];
    [followingActivitiesQuery whereKeyExists:kFTActivityToUserKey];
    [followingActivitiesQuery includeKey:kFTActivityToUserKey];
    [followingActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *following = [[NSMutableArray alloc] init];
            
            for (PFUser *followed in objects) {
                if ([followed objectForKey:kFTActivityToUserKey]) {
                    [following addObject:[followed objectForKey:kFTActivityToUserKey]];
                }
            }
            
            self.objects = following;
            [self.tableView reloadData];
        }
    }];
}

- (void)queryForFollowers {
        
    self.objects = nil;
    [self.tableView reloadData];
    
    // List of all users following current user
    PFQuery *followerActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followerActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followerActivitiesQuery whereKey:kFTActivityToUserKey equalTo:self.user];
    [followerActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [followerActivitiesQuery setLimit:1000];
    [followerActivitiesQuery whereKeyExists:kFTActivityFromUserKey];
    [followerActivitiesQuery includeKey:kFTActivityFromUserKey];
    [followerActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *followers = [[NSMutableArray alloc] init];
            
            for (PFUser *follower in objects) {
                if ([follower objectForKey:kFTActivityFromUserKey]) {
                    [followers addObject:[follower objectForKey:kFTActivityFromUserKey]];
                }
            }
            
            self.objects = followers;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FTFollowCell *cell = (FTFollowCell *)[tableView dequeueReusableCellWithIdentifier:DATACELL_IDENTIFIER];
    if (cell == nil) {
        cell = [[FTFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DATACELL_IDENTIFIER];
        cell.delegate = self;
    }
    
    if(indexPath.row != self.objects.count-1){
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
        line.backgroundColor = [UIColor whiteColor];
        [cell addSubview:line];
    }
    
    [cell setUser:self.objects[indexPath.row]];
    
    return cell;
}

#pragma mark - FTFollowCellDelegate

- (void)followCell:(FTFollowCell *)inviteCell didTapProfileImage:(UIButton *)button user:(PFUser *)aUser {
    //NSLog(@"%@::followCell:didTapProfileImage:user",VIEWCONTROLLER_INVITE);
    if (profileViewController) {
        profileViewController = nil;
    }
    
    profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController.navigationItem setLeftBarButtonItem:backIndicator];
    [profileViewController setUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)followCell:(FTFollowCell *)inviteCell didTapFollowButton:(UIButton *)button user:(PFUser *)aUser {
    
}

#pragma mark - ()

- (void)didTapBackButtonAction:(UIBarButtonItem *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
