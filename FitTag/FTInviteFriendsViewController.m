//
//  FTInviteFriendsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInviteFriendsViewController.h"
#import "FTUserProfileViewController.h"

#define DATACELL_IDENTIFIER @"DataCell"
#define TABLE_VIEW_HEIGHT 80

@interface FTInviteFriendsViewController()
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) FTUserProfileViewController *profileViewController;
@end

@implementation FTInviteFriendsViewController
@synthesize flowLayout;
@synthesize profileViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *grayColor = [UIColor colorWithRed:FT_GRAY_COLOR_RED
                                         green:FT_GRAY_COLOR_GREEN
                                          blue:FT_GRAY_COLOR_BLUE
                                         alpha:1.0f];
    
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // Set background image
    [self.tableView setBackgroundColor:grayColor];
    
    // Fittag navigationbar color
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                                                           green:FT_RED_COLOR_GREEN
                                                                            blue:FT_RED_COLOR_BLUE
                                                                           alpha:1.0f];
    
    FTInviteTableHeaderView *headerView = [[FTInviteTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TABLE_VIEW_HEIGHT)];
    headerView.delegate = self;
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.delegate = self;
    
    [self queryForUserType:FTFollowUserQueryTypeNear];
    
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(320,335)];
    
    profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (void)queryForUserType:(FTFollowUserQueryType)type {
    
    // List of all users being followed by the current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [followingActivitiesQuery includeKey:kFTActivityToUserKey];
    [followingActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *followedUserIds = [[NSMutableArray alloc] init];
            
            // Obtain an array of object ids for all users being followed
            for (PFObject *object in objects) {
                PFUser *followedUser = [object objectForKey:kFTActivityToUserKey];
                [followedUserIds addObject:followedUser.objectId];
            }
            
            switch (type) {
                case FTFollowUserQueryTypeNear: {
                    
                    PFGeoPoint *geoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
                    
                    // List of all users within 50 miles that are not already being followed
                    PFQuery *followUsersByLocationQuery = [PFQuery queryWithClassName:kFTUserClassKey];
                    [followUsersByLocationQuery whereKey:kFTUserObjectIdKey notEqualTo:[PFUser currentUser].objectId];
                    [followUsersByLocationQuery whereKey:kFTUserLocationKey nearGeoPoint:geoPoint withinMiles:LOCATION_USERS_WITHIN_MILES];
                    [followUsersByLocationQuery whereKeyExists:kFTUserLocationKey];
                    [followUsersByLocationQuery whereKey:kFTUserObjectIdKey notContainedIn:followedUserIds];
                    [followUsersByLocationQuery setLimit:100];
                    [followUsersByLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            self.objects = objects;
                            [self.tableView reloadData];
                        }
                    }];
                }
                    break;
                    
                case FTFollowUserQueryTypeInterest: {
                    
                    NSArray *interests = [[PFUser currentUser] objectForKey:kFTUserInterestsKey];
                    
                    PFQuery *followUsersByInterestQuery = [PFQuery queryWithClassName:kFTUserClassKey];
                    [followUsersByInterestQuery whereKey:kFTUserObjectIdKey notEqualTo:[PFUser currentUser].objectId];
                    [followUsersByInterestQuery whereKey:kFTUserInterestsKey containedIn:interests];
                    [followUsersByInterestQuery whereKeyExists:kFTUserInterestsKey];
                    [followUsersByInterestQuery whereKey:kFTUserObjectIdKey notContainedIn:followedUserIds];
                    [followUsersByInterestQuery setLimit:100];
                    [followUsersByInterestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            self.objects = objects;
                            [self.tableView reloadData];
                        }
                    }];
                    
                }
                    break;
                    
                default:
                    break;
            }
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
    [profileViewController setUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)followCell:(FTFollowCell *)inviteCell didTapFollowButton:(UIButton *)button user:(PFUser *)aUser {
    
}

#pragma mark - FTInviteTableHeaderViewDelegate

- (void)inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView didTapInterestButton:(UIButton *)button {
    [self queryForUserType:FTFollowUserQueryTypeInterest];
}

- (void)inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView didTapLocationButton:(UIButton *)button {
    [self queryForUserType:FTFollowUserQueryTypeNear];
}

@end
