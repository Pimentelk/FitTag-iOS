//
//  OffersViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsViewController.h"
#import "FTRewardsCollectionViewCell.h"
#import "FTRewardsDetailView.h"

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
    [self.collectionView setBackgroundColor:FT_GRAY];
    
    [self.collectionView registerClass:[FTRewardsCollectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:REUSE_IDENTIFIER_HEADERVIEW];
    
    // Data view
    [self.collectionView registerClass:[FTRewardsCollectionViewCell class]
            forCellWithReuseIdentifier:REUSE_IDENTIFIER_DATACELL];
    
    
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
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    if ([status isEqual:kFTRewardTypeUsed]) {
        NSLog(@"Used...");
        PFQuery *usedQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
        [usedQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeRedeem];
        [usedQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        [usedQuery includeKey:kFTActivityRewardKey];
        [usedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSMutableArray *tmpRewards = [[NSMutableArray alloc] init];
                for (PFObject *object in objects) {
                    if ([object objectForKey:kFTActivityRewardKey]) {
                       [tmpRewards addObject:[object objectForKey:kFTActivityRewardKey]];
                    }
                }
                
                if (tmpRewards.count > 0) {
                    self.rewards = tmpRewards;
                } else {
                    self.rewards = nil;
                }
                
                [self.collectionView reloadData];
            }
            
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        return;
    }
    
    PFQuery *deletedRewardQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [deletedRewardQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeDelete];
    [deletedRewardQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [deletedRewardQuery includeKey:kFTActivityRewardKey];
    [deletedRewardQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            
            NSMutableArray *deletedRewards = [[NSMutableArray alloc] init];
            for (PFObject *activity in activities) {
                if ([activity objectForKey:kFTActivityRewardKey]) {
                    PFObject *reward = [activity objectForKey:kFTActivityRewardKey];
                    [deletedRewards addObject:reward.objectId];
                }
            }
            NSLog(@"deletedRewards:%@",deletedRewards);
            
            if (![status isEqual:kFTRewardTypeUsed]) {
                
                PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
                [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
                [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
                followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
                
                PFQuery *query = [PFQuery queryWithClassName:kFTRewardClassKey];
                [query whereKey:kFTRewardUserKey matchesKey:kFTActivityToUserKey inQuery:followingActivitiesQuery];
                [query whereKey:@"objectId" notContainedIn:deletedRewards];
                [query whereKey:kFTRewardStatusKey equalTo:status];
                [query includeKey:kFTRewardUserKey];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        self.rewards = objects;
                        [self.collectionView reloadData];
                    }
                    
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }
    }];
}

#pragma mark - UICollectionView

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
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

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@::collectionView:didSelectItemAtIndexPath:",VIEWCONTROLLER_REWARDS);
    
    //NSLog(@"indexpath: %ld",(long)indexPath.row);
    FTRewardsDetailView *rewardsDetailView = [[FTRewardsDetailView alloc] initWithReward:self.rewards[indexPath.row]];
    [self.navigationController pushViewController:rewardsDetailView animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%@::collectionView:cellForItemAtIndexPath:",VIEWCONTROLLER_REWARDS);
    
    // Set up cell identifier that matches the Storyboard cell name
    static NSString *identifier = REUSE_IDENTIFIER_DATACELL;
    FTRewardsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
  
    if ([cell isKindOfClass:[FTRewardsCollectionViewCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
        
        PFObject *object = self.rewards[indexPath.row];
        PFFile *file = [object objectForKey:kFTRewardImageKey];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [cell setImage:[UIImage imageWithData:data]];
                [cell setLabelText:[object objectForKey:kFTRewardNameKey]];
            } else {
                NSLog(@"Error trying to download image..");
            }
        }];
    }
    
    return cell;
}

#pragma mark - FTRewardsHeaderViewDelegate

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapActiveTab:(id)tab {
    //NSLog(@"%@::rewardsHeaderView:didTapActiveButton:",VIEWCONTROLLER_REWARDS);
    [self queryForTable:REWARDS_FILTER_ACTIVE];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapExpiredTab:(id)tab {
    //NSLog(@"%@::rewardsHeaderView:didTapExpiredButton:",VIEWCONTROLLER_REWARDS);
    [self queryForTable:REWARDS_FILTER_EXPIRED];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapUsedTab:(id)tab {
    //NSLog(@"%@::rewardsHeaderView:didTapUsedButton:",VIEWCONTROLLER_REWARDS);
    [self queryForTable:REWARDS_FILTER_USED];
}

@end
