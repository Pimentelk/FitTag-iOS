//
//  UITableView+FTProfileTimelineViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileCollectionViewController.h"
#import "FTUserProfileCollectionViewController.h"
#import "FTUserProfileCollectionViewCell.h"
#import "FTPostDetailsViewController.h"
#import "FTCamViewController.h"


#define GRID_SMALL @"SMALLGRID"
#define GRID_FULL @"FULGRID"
#define GRID_BUSINESS @"BUSINESS"
#define GRID_TAGGED @"TAGGED"

#define DATACELL @"DataCell"
#define HEADERVIEW @"HeaderView"

@interface FTUserProfileCollectionViewController() <UICollectionViewDataSource,UICollectionViewDelegate> {
    NSString *cellTab;
}
@property (nonatomic, strong) NSArray *cells;
@end

@implementation FTUserProfileCollectionViewController
@synthesize user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
    }
    
    cellTab = GRID_SMALL;
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:[user objectForKey:kFTUserDisplayNameKey]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set Background
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Data view
    [self.collectionView registerClass:[FTUserProfileCollectionViewCell class]
            forCellWithReuseIdentifier:DATACELL];
    
    [self.collectionView registerClass:[FTUserProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HEADERVIEW];
    
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    [self queryForTable:self.user];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Get the classname of the next view controller
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack-1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqual:VIEWCONTROLLER_CAM]){
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)queryForTable:(PFUser *)aUser {
    // Show HUD view
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    PFQuery *postsFromUserQuery = [PFQuery queryWithClassName:kFTPostClassKey];
    [postsFromUserQuery whereKey:kFTPostUserKey equalTo:aUser];
    [postsFromUserQuery whereKey:kFTPostTypeKey containedIn:@[kFTPostTypeImage,kFTPostTypeVideo,kFTPostTypeGallery]];
    [postsFromUserQuery orderByDescending:@"createdAt"];
    [postsFromUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //NSLog(@"cells: %@",self.cells);
            self.cells = objects;
            //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - UICollectionView

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        FTUserProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                       withReuseIdentifier:@"HeaderView"
                                                                                              forIndexPath:indexPath];
        
        [headerView setDelegate: self];
        [headerView setUser: self.user];
        [headerView fetchUserProfileData: self.user];
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cells.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexpath: %ld",(long)indexPath.row);
    if ([cellTab isEqualToString:kFTUserTypeBusiness]) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(105.5,105)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setMinimumLineSpacing:0];
        [flowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
        [flowLayout setHeaderReferenceSize:CGSizeMake(320,356)];
        
        PFUser *business = self.cells[indexPath.row];
        NSLog(@"FTUserProfileCollectionViewController:: business: %@",business);
        if (business) {
            FTBusinessProfileCollectionViewController *businessProfileViewController = [[FTBusinessProfileCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
            [businessProfileViewController setBusiness:business];
            [self.navigationController pushViewController:businessProfileViewController animated:YES];
        }
        
    } else {
        
        FTPostDetailsViewController *postDetailView = [[FTPostDetailsViewController alloc] initWithPost:self.cells[indexPath.row] AndType:nil];
        [self.navigationController pushViewController:postDetailView animated:YES];
        
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set up cell identifier that matches the Storyboard cell name
    static NSString *identifier = @"DataCell";
    FTUserProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[FTUserProfileCollectionViewCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
        if ([cellTab isEqualToString:kFTUserTypeBusiness]) {
            NSLog(@"self.cells: %@", self.cells[indexPath.row]);
            PFUser *business = self.cells[indexPath.row];
            [cell setUser:business];
        } else {
            PFObject *object = self.cells[indexPath.row];
            [cell setPost:object];
        }
    }
    
    return cell;
}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(self.view.frame.size.width, 60);
}
*/

#pragma mark - Navigation Bar

- (void)didTapLoadCameraButtonAction:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:camViewController animated:YES];
}

/*
- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}
*/

#pragma mark - FTUserProfileCollectionHeaderViewDelegate

- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileCollectionHeaderView
                       didTapGridButton:(UIButton *)button {
    cellTab = GRID_SMALL;
    [self queryForTable:self.user];
}

- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileCollectionHeaderView
                   didTapBusinessButton:(UIButton *)button {
    
    cellTab = kFTUserTypeBusiness; // kFTUserTypeBusiness | SMALLGRID | FULLGRID | TAGGED
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    PFQuery *followingBusinessActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingBusinessActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingBusinessActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [followingBusinessActivitiesQuery includeKey:kFTActivityToUserKey];
    followingBusinessActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    [followingBusinessActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *businesses = [[NSMutableArray alloc] init];
            for (PFObject *object in objects){
                PFUser *business = [object objectForKey:kFTActivityToUserKey];
                if ([[business objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                    [businesses addObject:business];
                }
            }
            self.cells = businesses;
            //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileCollectionHeaderView
                     didTapTaggedButton:(UIButton *)button {
    
    cellTab = GRID_TAGGED;
    NSMutableString *displayName = [[self.user objectForKey:kFTUserDisplayNameKey] mutableCopy];
    NSString *mentionTag = [displayName stringByReplacingOccurrencesOfString:@"@"
                                                                  withString:@""];
    
    NSMutableArray *userMention = [[NSMutableArray alloc] init];
    [userMention addObject:[NSString stringWithFormat:@"%@",mentionTag]];
    
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    PFQuery *postsWhereMentionedQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [postsWhereMentionedQuery whereKey:kFTActivityMentionKey containedIn:userMention];
    [postsWhereMentionedQuery includeKey:kFTActivityPostKey];
    [postsWhereMentionedQuery setCachePolicy: kPFCachePolicyNetworkOnly];
    [postsWhereMentionedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *posts = [[NSMutableArray alloc] init];
            for (PFObject *activity in objects) {
                if ([activity objectForKey:kFTActivityPostKey]) {
                    [posts addObject:[activity objectForKey:kFTActivityPostKey]];
                }
            }
            self.cells = posts;
            //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileCollectionHeaderView
                   didTapSettingsButton:(id)sender {
    
}

@end
