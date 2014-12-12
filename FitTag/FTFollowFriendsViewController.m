//
//  FTFollowFriendsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFollowFriendsViewController.h"
#import "FTUserProfileViewController.h"

#define DATACELL_IDENTIFIER @"DataCell"
#define TABLE_VIEW_HEIGHT 80

@interface FTFollowFriendsViewController()
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) FTUserProfileViewController *profileViewController;
@property (nonatomic, strong) FTInviteTableHeaderView *headerView;
@property (nonatomic, strong) FTLocationManager *locationManager;
@property (nonatomic, strong) UIBarButtonItem *backIndicator;
@end

@implementation FTFollowFriendsViewController
@synthesize flowLayout;
@synthesize profileViewController;
@synthesize followUserQueryType;
@synthesize headerView;
@synthesize locationManager;
@synthesize backIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[FTLocationManager alloc] init];
    [locationManager requestLocationAuthorization];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // Set background image
    [self.tableView setBackgroundColor:FT_GRAY];
    [self.tableView setDelegate:self];
    
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
    
    // Table headerview
    headerView = [[FTInviteTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    headerView.delegate = self;
    
    [headerView setLocationSelected];
    
    if (followUserQueryType & FTFollowUserQueryTypeTagger) {
        [self.tableView.tableHeaderView setHidden:YES];
        [self querySearchForUser];
    } else {
        [self.tableView setTableHeaderView:headerView];
        [self.tableView.tableHeaderView setHidden:NO];
        [self queryForUserType:FTFollowUserQueryTypeDefault];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_FOLLOW];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - ()

- (void)querySearchForUser {
    // List of all users where handle matches string OR handle contains substring
    //NSLog(@"self.searchString: %@",self.searchString);
    
    if (self.searchString && ![self.searchString isEqualToString:EMPTY_STRING]) {
        
        //****** Display Name ********//
        PFQuery *queryStringMatchHandle = [PFQuery queryWithClassName:kFTUserClassKey];
        [queryStringMatchHandle whereKeyExists:kFTUserDisplayNameKey];
        [queryStringMatchHandle whereKey:kFTUserDisplayNameKey equalTo:self.searchString];
        
        PFQuery *querySubStringHandle = [PFQuery queryWithClassName:kFTUserClassKey];
        [querySubStringHandle whereKeyExists:kFTUserDisplayNameKey];
        [querySubStringHandle whereKey:kFTUserDisplayNameKey containsString:self.searchString];
        
        //****** First Name ********//
        PFQuery *queryStringMatchFirstName = [PFQuery queryWithClassName:kFTUserClassKey];
        [queryStringMatchFirstName whereKeyExists:kFTUserFirstnameKey];
        [queryStringMatchFirstName whereKey:kFTUserFirstnameKey equalTo:self.searchString];
        
        PFQuery *querySubStringFirstName = [PFQuery queryWithClassName:kFTUserClassKey];
        [querySubStringFirstName whereKeyExists:kFTUserFirstnameKey];
        [querySubStringFirstName whereKey:kFTUserFirstnameKey containsString:self.searchString];
        
        //****** Last Name ********//
        PFQuery *queryStringMatchLastName = [PFQuery queryWithClassName:kFTUserClassKey];
        [queryStringMatchLastName whereKeyExists:kFTUserLastnameKey];
        [queryStringMatchLastName whereKey:kFTUserLastnameKey equalTo:self.searchString];
        
        PFQuery *querySubStringLastName = [PFQuery queryWithClassName:kFTUserClassKey];
        [querySubStringLastName whereKeyExists:kFTUserLastnameKey];
        [querySubStringLastName whereKey:kFTUserLastnameKey containsString:self.searchString];
        
        NSArray *queries = @[ queryStringMatchHandle, querySubStringHandle, queryStringMatchFirstName,
                              querySubStringFirstName, queryStringMatchLastName, querySubStringLastName ];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
        [query findObjectsInBackgroundWithBlock:^(NSArray *taggers, NSError *error) {
            if (!error) {
                if (taggers.count > 0) {
                    self.objects = taggers;
                    [self.tableView reloadData];
                } else {
                    //IMAGE_NO_RESULTS
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:IMAGE_NO_RESULTS];
                    [imageView setFrame:CGRectMake((self.tableView.frame.size.width - 130) / 2, (self.tableView.frame.size.width - 156) / 2, 130, 156)];
                    [self.tableView addSubview:imageView];
                }
            }
        }];
    }
}

- (void)queryForUserType:(FTFollowUserQueryType)type {
    
    NSLog(@"%@::queryForUserType",VIEWCONTROLLER_INVITE);
    
    // List of all users being followed by the current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [followingActivitiesQuery includeKey:kFTActivityToUserKey];
    [followingActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *followedUsers, NSError *error) {
        if (!error) {
            NSMutableArray *followedUserIds = [[NSMutableArray alloc] init];
            
            // Obtain an array of object ids for all users being followed
            for (PFObject *aFollowedUser in followedUsers) {
                PFUser *followedUser = [aFollowedUser objectForKey:kFTActivityToUserKey];                
                if (followedUser.objectId) {
                    [followedUserIds addObject:followedUser.objectId];
                }
            }
            
            switch (type) {
                case FTFollowUserQueryTypeNear: {
                    
                    if (![[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
                        [[[UIAlertView alloc] initWithTitle:@"User Location Error"
                                                    message:@"User location needs to be enabled to find users near you."
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil] show];
                        return;
                    }
                    
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
                    
                    if (![[PFUser currentUser] objectForKey:kFTUserInterestsKey]) {
                        [[[UIAlertView alloc] initWithTitle:@"User Interest Error"
                                                    message:@"User interest needs to be selected to find friends."
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil] show];
                        return;
                    }
                    
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

#pragma mark - FTInviteTableHeaderViewDelegate

- (void)inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
         didTapInterestButton:(UIButton *)button {
    [self queryForUserType:FTFollowUserQueryTypeInterest];
}

- (void)inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
         didTapLocationButton:(UIButton *)button {
    [self queryForUserType:FTFollowUserQueryTypeNear];
}

#pragma mark - ()

- (void)didTapBackButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
