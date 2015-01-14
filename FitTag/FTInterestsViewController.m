//
//  InterestsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInterestsViewController.h"
#import "FTInterestCell.h"
//#import "FTInspirationViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTCollectionHeaderView.h"
#import "FTFlowLayout.h"

#define BACKGROUND_IMAGE_INTERESTS @"login_background_image_03"
#define DATACELL @"DataCell"
#define HEADERVIEW @"HeaderView"
#define FOOTERVIEW @"FooterView"

@interface FTInterestsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSMutableArray *selectedInterests;
    NSMutableArray *userInterests;
}

@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *continueMessage;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) FTLocationManager *locationManager;
@property (nonatomic, strong) FTFollowFriendsViewController *followFriendsViewController;
//@property (nonatomic, strong) FTInspirationViewController *inspirationViewController;
@property (nonatomic) BOOL locationUpdated;
@end

@implementation FTInterestsViewController
@synthesize user;
@synthesize delegate;
@synthesize continueMessage;
@synthesize continueButton;
@synthesize locationManager;
//@synthesize inspirationViewController;
@synthesize followFriendsViewController;
@synthesize locationUpdated;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationUpdated = NO;
    
    // manage user location
    locationManager = [[FTLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    if (![PFUser currentUser]) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
        return;
    }
    
    // set the current user
    user = [PFUser currentUser];
    
    // Init Selected Interests Array
    selectedInterests = [NSMutableArray array];
    
    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND_IMAGE_INTERESTS]]];
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    // Override the back idnicator
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    
    // Back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Data view
    [self.collectionView registerClass:[FTInterestCell class] forCellWithReuseIdentifier:DATACELL];
    [self.collectionView registerClass:[FTCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADERVIEW];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    // Collection view
    [self.collectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.collectionView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            NSLog(@"%@:object: %@",VIEWCONTROLLER_INTERESTS,object);
            
            if ([object objectForKey:kFTUserInterestsKey]) {
                userInterests = [[NSMutableArray alloc] initWithArray:[object objectForKey:kFTUserInterestsKey]];
                NSLog(@"userInterests: %@",userInterests);
            }
            
            PFQuery *query = [PFQuery queryWithClassName:kFTInterestsClassKey];
            [query findObjectsInBackgroundWithBlock:^(NSArray *interests, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %lu scores.", (unsigned long)interests.count);
                    // Do something with the found objects
                    
                    NSMutableArray *tmpInterests = [NSMutableArray array];
                    
                    for (PFObject *interest in interests) {
                        if([interest objectForKey:kFTInterestKey]){
                            [tmpInterests addObject:[interest objectForKey:kFTInterestKey]];
                        }
                    }
                    
                    self.interests = tmpInterests;
                    [self.collectionView reloadData];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [locationManager requestLocationAuthorization];
    
    // Toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
    
    // Label
    continueMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 280, 30)];
    continueMessage.numberOfLines = 0;
    continueMessage.text = @"SELECT AT LEAST 3 INTERESTS";
    continueMessage.font = MULIREGULAR(16);
    continueMessage.backgroundColor = [UIColor clearColor];
    
    // Continue Button
    continueButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4, 34, 37)];
    [continueButton setBackgroundImage:[UIImage imageNamed:IMAGE_SIGNUP_BUTTON] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(didTapContinueButtonAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:continueMessage];
    [self.navigationController.toolbar addSubview:continueButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INTERESTS];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [continueMessage removeFromSuperview];
    [continueButton removeFromSuperview];
    
    continueButton = nil;
    continueMessage = nil;
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - FTLocationManagerDelegate

- (void)locationManager:(FTLocationManager *)locationManager didUpdateUserLocation:(CLLocation *)location geoPoint:(PFGeoPoint *)aGeoPoint {
    locationUpdated = YES;
}

- (void)locationManager:(FTLocationManager *)locationManager didFailWithError:(NSError *)error {
    locationUpdated = NO;
}

#pragma mark - InterestViewController

- (void)didTapContinueButtonAction:(UIButton *)button {
    
    if (selectedInterests.count < 3) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil)
                                    message:NSLocalizedString(@"Make sure you select 3 interests!", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    if (!user) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil)
                                    message:NSLocalizedString(@"Make sure you're logged in", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
        [self dismissViewControllerAnimated:YES completion:NULL];
        return;
    }
    
    //NSLog(@"Selected Interests: %@",selectedInterests);
    
    // Save selected interests here...
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
    
    [user setObject:selectedInterests forKey:kFTUserInterestsKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
            
            //NSLog(@"interests were saved successfully..");
            if (delegate && [delegate respondsToSelector:@selector(interestsViewController:didUpdateUserInterests:)]) {
                [delegate interestsViewController:self didUpdateUserInterests:selectedInterests];
            }
            
            // Show the interests
            UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
            [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
            [backIndicator setStyle:UIBarButtonItemStylePlain];
            [backIndicator setTarget:self];
            [backIndicator setAction:@selector(didTapPopButtonAction:)];
            [backIndicator setTintColor:[UIColor whiteColor]];
            
            UIBarButtonItem *doneIndicator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapBackButtonAction:)];
            [doneIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
            [doneIndicator setStyle:UIBarButtonItemStylePlain];
            [doneIndicator setTintColor:[UIColor whiteColor]];
            
            followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
            followFriendsViewController.followUserQueryType = FTFollowUserQueryTypeInterest;
            [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
            [followFriendsViewController.navigationItem setRightBarButtonItem:doneIndicator];
            [self.navigationController pushViewController:followFriendsViewController animated:YES];
            
        }
        
        if (error) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
            
            NSLog(@"Error: saveEventually... %@", error);
            //[user saveEventually];
        }
    }];
    
    if (self.isFirstLaunch) {
        // If this is part of the first time launch flow show the inspiration screen next.
        // only if the location has been updated
        //[self.navigationController pushViewController:inspirationViewController animated:YES];
        return;
    }
    
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        FTCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:HEADERVIEW
                                                                                     forIndexPath:indexPath];
        
        UILabel *messageHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 15)];
        messageHeader.numberOfLines = 0;
        messageHeader.text = @"WHAT INSPIRES YOU?";
        messageHeader.font = MULIREGULAR(18);
        messageHeader.backgroundColor = [UIColor clearColor];
        messageHeader.textAlignment = NSTextAlignmentCenter;
        
        UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, self.view.frame.size.width, 55)];
        messageText.numberOfLines = 0;
        messageText.text = @"What inspires you to reach your fitness goals? A new healthy recipe, a muscle building exercise? Tell us and we will find content you'll love!";
        messageText.backgroundColor = [UIColor clearColor];
        messageText.textAlignment = NSTextAlignmentCenter;
        messageText.font = [UIFont systemFontOfSize:12];
        
        headerView.messageHeader = messageHeader;
        headerView.messageText = messageText;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:FOOTERVIEW
                                                                                         forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section {
    return self.interests.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FTInterestCell *cell = (FTInterestCell *)[collectionView dequeueReusableCellWithReuseIdentifier:DATACELL forIndexPath:indexPath];
    if ([cell isKindOfClass:[FTInterestCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
        cell.interestLabel.text = self.interests[indexPath.row];
        cell.interestLabel.font = MULIREGULAR(16);
        
        BOOL isFirstCell = NO;
        if(indexPath.row % 2 == 0){
            isFirstCell = YES;
        }
        
        if (isFirstCell){
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width, 0, 1, cell.frame.size.height)];
            divider.backgroundColor = [UIColor lightGrayColor];
            [cell addSubview:divider];
        }
        
        if ([userInterests containsObject:self.interests[indexPath.row]]) {
            [cell setCellSelection];
            [selectedInterests addObject:self.interests[indexPath.row]];
        }
    }
    return cell;
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
    FTInterestCell *cell = (FTInterestCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isSelectedToggle]) {
        [selectedInterests addObject:self.interests[indexPath.row]];
    } else {
        [selectedInterests removeObject:self.interests[indexPath.row]];
    }
}

#pragma mark - ()

- (void)didTapPopButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapBackButtonAction:(id)sender {
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
