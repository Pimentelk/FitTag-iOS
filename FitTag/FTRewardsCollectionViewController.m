//
//  OffersViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsCollectionViewController.h"
#import "FTCamViewController.h"
#import "FTActivityFeedViewController.h"
#import "FTSearchViewController.h"
#import "FTAccountViewController.h"
#import "FTRewardsCollectionViewCell.h"
#import "FTRewardsDetailView.h"
#import "MBProgressHUD.h"

@interface FTRewardsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *rewards;
@end

@implementation FTRewardsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle: @"REWARDS"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    UIBarButtonItem *loadCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"] style:UIBarButtonItemStylePlain target:self action:@selector(loadCamera:)];
    
    [backIndicator setTintColor:[UIColor whiteColor]];
    [loadCamera setTintColor:[UIColor whiteColor]];

    [self.navigationItem setLeftBarButtonItem:backIndicator];
    [self.navigationItem setRightBarButtonItem:loadCamera];

    // Set Background
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:154/255.0f green:154/255.0f blue:154/255.0f alpha:1]];
    
    // Data view
    [self.collectionView registerClass:[FTRewardsCollectionViewCell class] forCellWithReuseIdentifier:@"DataCell"];
    [self.collectionView registerClass:[FTRewardsCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    [self queryForTable:@"ACTIVE"];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Get the classname of the next view controller
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack-1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqual: @"FTCamViewController"]){
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)queryForTable:(NSString *)status {
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    if (![status isEqual:kFTRewardsTypeUsed]) {
        
        PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
        [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
        [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        followingActivitiesQuery.limit = 100;
    
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

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        FTRewardsCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                       withReuseIdentifier:@"HeaderView"
                                                                                              forIndexPath:indexPath];
        headerView.delegate = self;
        reusableview = headerView;
    }
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rewards.count;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexpath: %ld",(long)indexPath.row);
    FTRewardsDetailView *rewardsDetailView = [[FTRewardsDetailView alloc] initWithReward:self.rewards[indexPath.row]];
    [self.navigationController pushViewController:rewardsDetailView animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set up cell identifier that matches the Storyboard cell name
    static NSString *identifier = @"DataCell";
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

-(void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapActiveButton:(UIButton *)button {
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.activeButton setSelected:YES];
    [self queryForTable:@"ACTIVE"];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapExpiredButton:(UIButton *)button {
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.expiredButton setSelected:YES];
    [self queryForTable:@"EXPIRED"];
}

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapUsedButton:(UIButton *)button {
    [rewardsHeaderView clearSelectedButtons];
    [rewardsHeaderView.usedButton setSelected:YES];
    [self queryForTable:@"USED"];
}

#pragma mark - Navigation Bar

- (void)loadCamera:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:camViewController animated:YES];
}

- (void)returnHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
