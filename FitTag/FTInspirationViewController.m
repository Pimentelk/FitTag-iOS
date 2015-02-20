//
//  InspirationViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/3/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInspirationViewController.h"
#import "FTCollectionHeaderView.h"
#import "FTInspirationCellCollectionView.h"
#import "FTInviteFriendsViewController.h"
#import "FTFlowLayout.h"

#define REUSABLE_IDENTIFIER_HEADER @"HeaderView"
#define REUSABLE_IDENTIFIER_MEMBER @"MemberCell"
#define REUSABLE_IDENTIFIER_FOOTER @"FooterView"

@interface FTInspirationViewController()
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) UILabel *continueMessage;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) PFGeoPoint *geoPoint;

@property (nonatomic, strong) FTInviteFriendsViewController *inviteFriendsViewController;
@end

@implementation FTInspirationViewController
@synthesize continueMessage;
@synthesize continueButton;
@synthesize geoPoint;
@synthesize inviteFriendsViewController;
@synthesize selectedUsers;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Update the users location
        
    if (![PFUser currentUser]) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
        return;
    }
    
    selectedUsers = [[NSMutableArray alloc] init];
    
    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND_INSPIRATIONAL]]];
    
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    // Register Cell
    [self.collectionView registerClass:[FTInspirationCellCollectionView class] forCellWithReuseIdentifier:REUSABLE_IDENTIFIER_MEMBER];
    
    // Register header
    [self.collectionView registerClass:[FTCollectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:REUSABLE_IDENTIFIER_HEADER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
        
    // Set collectionview frame
    [self.collectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.collectionView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    // Back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    if ([[PFUser currentUser] objectForKey:kFTUserInterestsKey]) {
        self.interests = [[PFUser currentUser] objectForKey:kFTUserInterestsKey];
    }
    
    // Layout param
    FTFlowLayout *inviteFriendsFlowLayout = [[FTFlowLayout alloc] init];
    [inviteFriendsFlowLayout setItemSize:CGSizeMake(self.view.frame.size.width,100)];
    [inviteFriendsFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [inviteFriendsFlowLayout setMinimumInteritemSpacing:0];
    [inviteFriendsFlowLayout setMinimumLineSpacing:0];
    [inviteFriendsFlowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [inviteFriendsFlowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,42)];
    
    inviteFriendsViewController = [[FTInviteFriendsViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    // Label
    continueMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 280, 30)];
    continueMessage.numberOfLines = 0;
    continueMessage.text = @"SELECT INSPIRING FOLLOWERS";
    continueMessage.font = MULIREGULAR(22);
    continueMessage.backgroundColor = [UIColor clearColor];
    
    // Toolbar
    continueButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4, 34, 37)];
    [continueButton setBackgroundImage:[UIImage imageNamed:IMAGE_SIGNUP_BUTTON] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(didTapContinueButtonAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:continueMessage];
    [self.navigationController.toolbar addSubview:continueButton];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INSPIRATION];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [continueMessage removeFromSuperview];
    [continueButton removeFromSuperview];
    
    continueButton = nil;
    continueMessage = nil;
}

- (void)queryForUsers {
    NSLog(@"qyeryForUsers");
    // Select all users who share similar interests
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
            
            PFQuery *sharedInterestQuery = [PFQuery queryWithClassName:kFTUserClassKey];
            [sharedInterestQuery whereKey:kFTUserObjectIdKey notEqualTo:[PFUser currentUser].objectId];
            [sharedInterestQuery whereKey:kFTUserObjectIdKey notContainedIn:followedUserIds];
            [sharedInterestQuery whereKey:kFTUserInterestsKey containedIn:self.interests];
            [sharedInterestQuery whereKeyExists:kFTUserInterestsKey];
            [sharedInterestQuery whereKeyExists:kFTUserProfilePicMediumKey];
            
            /*
            if (geoPoint) {
                PFQuery *nearbyQuery = [PFQuery queryWithClassName:kFTUserClassKey];
                [nearbyQuery whereKey:kFTUserLocationKey nearGeoPoint:geoPoint withinMiles:LOCATION_USERS_WITHIN_MILES];
                [nearbyQuery whereKeyExists:kFTUserLocationKey];
                
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[ sharedInterestQuery, nearbyQuery ]];
                [query setLimit:50];
                [query orderByAscending:@"createdAt"];
                [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                    if (!error) {
                        NSLog(@"number of users:%lu",(unsigned long)users.count);
                        self.usersToRecommend = users;
                        [self.collectionView reloadData];
                    }
                }];
                return;
            }
            */
            
            [sharedInterestQuery setLimit:50];
            [sharedInterestQuery orderByAscending:@"createdAt"];
            [sharedInterestQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
            [sharedInterestQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (!error) {
                    //NSLog(@"number of users:%lu",(unsigned long)users.count);
                    self.usersToRecommend = users;
                    [self.collectionView reloadData];
                }
            }];
        }
    }];
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        FTCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                withReuseIdentifier:REUSABLE_IDENTIFIER_HEADER
                                                                                       forIndexPath:indexPath];
        
        UILabel *messageHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 24)];
        messageHeader.numberOfLines = 0;
        messageHeader.text = @"FIND THE PEOPLE THAT INSPIRE YOU";
        messageHeader.font = MULIREGULAR(22);
        messageHeader.backgroundColor = [UIColor clearColor];
        messageHeader.textAlignment = NSTextAlignmentCenter;
        
        UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, self.view.frame.size.width, 55)];
        messageText.numberOfLines = 0;
        messageText.text = EMPTY_STRING;
        messageText.backgroundColor = [UIColor clearColor];
        messageText.textAlignment = NSTextAlignmentCenter;
        messageText.font = [UIFont systemFontOfSize:12];
        
        headerView.messageHeader = messageHeader;
        headerView.messageText = messageText;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:REUSABLE_IDENTIFIER_FOOTER
                                                                                         forIndexPath:indexPath];
        reusableview = footerview;
    }
    
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.usersToRecommend.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FTInspirationCellCollectionView *cell = (FTInspirationCellCollectionView *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSABLE_IDENTIFIER_MEMBER
                                                                                                                         forIndexPath:indexPath];
    PFUser *userToRecommend = self.usersToRecommend[indexPath.row];
    NSMutableArray *sharedInterests = [self intersect:self.interests withUser:[userToRecommend objectForKey:kFTUserInterestsKey]];
    
    //NSString *interest = [[sharedInterests componentsJoinedByString:@"\r\n"] uppercaseString];
    NSString *interest = [[sharedInterests componentsJoinedByString:@" "] uppercaseString];

    NSLog(@"Matching interests: %@",interest);
    
    if (cell == nil) {
        cell = [[FTInspirationCellCollectionView alloc] init];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.message.text = @"BECAUSE YOU HAVE INTEREST IN ";
    cell.messageInterests.text = interest;
    cell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
    
    PFFile *file = [userToRecommend objectForKey:kFTUserProfilePicSmallKey];
    if (file) {
        cell.imageView.file = file;
        // PFQTVC will take care of asynchronously downloading files, but will only
        // load them when the tableview is not moving. If the data is there, let's load it right away.
        if ([cell.imageView.file isDataAvailable]) {
            [cell.imageView loadInBackground];
        }
    }
    
    if ([self.selectedUsers containsObject:userToRecommend.objectId]) {
        cell.isSelectedToggle = YES;
        cell.image = [UIImage imageNamed:@"user_selected"];
    }
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // When item is selected do something
    FTInspirationCellCollectionView *cell = (FTInspirationCellCollectionView *)[collectionView cellForItemAtIndexPath:indexPath];
    PFUser *userToRecommend = self.usersToRecommend[indexPath.row];
    
    if(![cell isSelectedToggle]){
        //NSLog(@"Item selected");
        [self didTapUserFollowAction:userToRecommend];
        
        cell.isSelectedToggle = YES;
        cell.image = [UIImage imageNamed:@"user_selected"];
        [self.selectedUsers addObject:userToRecommend.objectId];
    } else {
        [self didTapUserUnfollowAction:userToRecommend];
        
        cell.isSelectedToggle = NO;
        PFFile *file = [userToRecommend objectForKey:kFTUserProfilePicSmallKey];
        if (file) {
            cell.imageView.file = file;
        }
    }
}

- (NSMutableArray *)intersect:(NSArray *)selected
                     withUser:(NSArray *)interests {
    NSMutableArray *sharedInterests = [[NSMutableArray alloc] init];
    for (NSObject *interest in selected) {
        if([interests containsObject:interest] && ![sharedInterests containsObject:interest])
            [sharedInterests addObject:interest];
    }
    return sharedInterests;
}

#pragma mark 

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapContinueButtonAction:(UIButton *)button {
    //[self.navigationController pushViewController:inviteFriendsViewController animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark follow/unfollow users

- (void)didTapUserFollowAction:(PFUser *)targetUser {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    [FTUtility followUserEventually:targetUser block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"followButtonAction::succeeded");
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
            
            if ([[targetUser objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
            }
        }
        
        if (error) {
            NSLog(@"unfollowButtonAction::error:%@",error);
        }
    }];
}

- (void)didTapUserUnfollowAction:(PFUser *)targetUser {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    
    [FTUtility unfollowUserEventually:targetUser block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"unfollowButtonAction::succeeded");
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
            
            if ([[targetUser objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
            }
        }
        
        if (error) {
            NSLog(@"unfollowButtonAction::error:%@",error);
        }
    }];
}

@end
