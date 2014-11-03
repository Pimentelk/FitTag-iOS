//
//  OffersViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsCollectionViewController.h"
#import "FTRewardsCollectionViewCell.h"
#import "FTRewardsDetailView.h"
#import "MBProgressHUD.h"

// Rewards Filter States
#define REWARDS_FILTER_ACTIVE @"ACTIVE"
#define REWARDS_FILTER_EXPIRED @"EXPIRED"
#define REWARDS_FILTER_USED @"USED"

// Reusable Identifiers
#define REUSE_IDENTIFIER_DATACELL @"DataCell"
#define REUSE_IDENTIFIER_HEADERVIEW @"HeaderView"

@interface FTRewardsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *rewards;
@end

@implementation FTRewardsCollectionViewController

- (void)viewDidLoad {
    NSLog(@"%@::viewDidLoad",VIEWCONTROLLER_REWARDS);
    [super viewDidLoad];
        
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:NAVIGATION_TITLE_REWARDS];

    // Set Background
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:FT_DARKGRAY_COLOR_RED
                                                            green:FT_DARKGRAY_COLOR_GREEN
                                                             blue:FT_DARKGRAY_COLOR_BLUE
                                                            alpha:1]];
    
    // Data view
    [self.collectionView registerClass:[FTRewardsCollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_DATACELL];
    [self.collectionView registerClass:[FTRewardsCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:REUSE_IDENTIFIER_HEADERVIEW];
    
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self queryForTable:REWARDS_FILTER_ACTIVE];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@::viewDidAppear",VIEWCONTROLLER_REWARDS);
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_REWARDS];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)queryForTable:(NSString *)status {
    NSLog(@"%@::queryForTable",VIEWCONTROLLER_REWARDS);
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    if (![status isEqual:kFTRewardsTypeUsed]) {
        
        PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
        [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
        [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        followingActivitiesQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
        PFQuery *query = [PFQuery queryWithClassName:kFTRewardsClassKey];
        [query whereKey:kFTRewardsUserKey matchesKey:kFTActivityToUserKey inQuery:followingActivitiesQuery];
        [query whereKey:kFTRewardsStatusKey equalTo:status];
        [query includeKey:kFTRewardsUserKey];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.rewards = objects;
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [self.collectionView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    } else {
    
        PFQuery *usedQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
        [usedQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeReward];
        [usedQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        [usedQuery includeKey:kFTActivityRewardsKey];
        [usedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSMutableArray *tmpRewards = [NSMutableArray array];
                for (PFObject *object in objects) {
                    [tmpRewards addObject:[object objectForKey:kFTActivityRewardsKey]];
                }
                self.rewards = tmpRewards;
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [self.collectionView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

#pragma mark - UICollectionView

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@::collectionView:viewForSupplementaryElementOfKind:atIndexPath:",VIEWCONTROLLER_REWARDS);
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        FTRewardsCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                       withReuseIdentifier:REUSE_IDENTIFIER_HEADERVIEW
                                                                                              forIndexPath:indexPath];
        headerView.delegate = self;
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@::collectionView:numberOfItemsInSection:",VIEWCONTROLLER_REWARDS);
    return self.rewards.count;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@::collectionView:didSelectItemAtIndexPath:",VIEWCONTROLLER_REWARDS);
    
    NSLog(@"indexpath: %ld",(long)indexPath.row);
    FTRewardsDetailView *rewardsDetailView = [[FTRewardsDetailView alloc] initWithReward:self.rewards[indexPath.row]];
    [self.navigationController pushViewController:rewardsDetailView animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@::collectionView:cellForItemAtIndexPath:",VIEWCONTROLLER_REWARDS);
    
    // Set up cell identifier that matches the Storyboard cell name
    static NSString *identifier = REUSE_IDENTIFIER_DATACELL;
    FTRewardsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
  
    if ([cell isKindOfClass:[FTRewardsCollectionViewCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
        
        PFObject *object = self.rewards[indexPath.row];
        PFFile *file = [object objectForKey:kFTRewardsImageKey];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [cell setImage:[UIImage imageWithData:data]];
                [cell setLabelText:[object objectForKey:kFTRewardsNameKey]];
            } else {
                NSLog(@"Error trying to download image..");
            }
        }];
    }
    
    return cell;
}

#pragma mark - FTRewardsHeaderViewDelegate

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapActiveButton:(UIButton *)button {
    NSLog(@"%@::rewardsHeaderView:didTapActiveButton:",VIEWCONTROLLER_REWARDS);
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.activeButton setSelected:YES];
    [self queryForTable:REWARDS_FILTER_ACTIVE];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapExpiredButton:(UIButton *)button {
    NSLog(@"%@::rewardsHeaderView:didTapExpiredButton:",VIEWCONTROLLER_REWARDS);
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.expiredButton setSelected:YES];
    [self queryForTable:REWARDS_FILTER_EXPIRED];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapUsedButton:(UIButton *)button {
    NSLog(@"%@::rewardsHeaderView:didTapUsedButton:",VIEWCONTROLLER_REWARDS);
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.usedButton setSelected:YES];
    [self queryForTable:REWARDS_FILTER_USED];
}

@end
