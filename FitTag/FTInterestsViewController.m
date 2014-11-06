//
//  InterestsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInterestsViewController.h"
#import "FTInterestCell.h"
#import "FTInspirationViewController.h"
#import "CollectionHeaderView.h"
#import "InterestFlowLayout.h"

#define BACKGROUND_IMAGE_INTERESTS @"login_background_image_03"
#define DATACELL @"DataCell"
#define HEADERVIEW @"HeaderView"
#define FOOTERVIEW @"FooterView"
#define SIGNUP_BUTTON @"signup_button"

@interface FTInterestsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSMutableArray *selectedInterests;
    NSMutableArray *userInterests;
}

@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) PFUser *user;
@end

@implementation FTInterestsViewController
@synthesize user;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the current user
    user = [PFUser currentUser];
    
    // Init Selected Interests Array
    selectedInterests = [NSMutableArray array];
    
    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND_IMAGE_INTERESTS]]];
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    // Override the back idnicator
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:FT_RED_COLOR_RED
                                                                             green:FT_RED_COLOR_GREEN
                                                                              blue:FT_RED_COLOR_BLUE alpha:1.0f]];
    
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
    [self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADERVIEW];
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    // Collection view
    [self.collectionView setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.collectionView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    // Label
    UILabel *nextMessage = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 280.0f, 30.0f)];
    nextMessage.numberOfLines = 0;
    nextMessage.text = @"SELECT AT LEAST 3 INTERESTS";
    nextMessage.backgroundColor = [UIColor clearColor];
    
    // Next button
    UIButton *submitInterests = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4.0f, 34.0f, 37.0f)];
    [submitInterests setBackgroundImage:[UIImage imageNamed:SIGNUP_BUTTON] forState:UIControlStateNormal];
    [submitInterests addTarget:self action:@selector(didTapSubmitInterestsButtonAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:nextMessage];
    [self.navigationController.toolbar addSubview:submitInterests];
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            NSLog(@"object: %@",object);
            
            if ([object objectForKey:kFTUserInterestsKey]) {
                userInterests = [[NSMutableArray alloc] initWithArray:[object objectForKey:kFTUserInterestsKey]];
                NSLog(@"userInterests: %@",userInterests);
            }
            
            PFQuery *query = [PFQuery queryWithClassName:kFTInterestsClassKey];
            [query findObjectsInBackgroundWithBlock:^(NSArray *interests, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    //NSLog(@"Successfully retrieved %lu scores.", (unsigned long)interests.count);
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
    
    // Toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INTERESTS];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - InterestViewController

- (void)didTapSubmitInterestsButtonAction:(UIButton *)button {
    
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
    
    NSLog(@"Selected Interests: %@",selectedInterests);
    
    // Save selected interests here...
    [user setObject:selectedInterests forKey:kFTUserInterestsKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"interests were saved successfully..");
            if (delegate && [delegate respondsToSelector:@selector(interestsViewController:didUpdateUserInterests:)]) {
                [delegate interestsViewController:self didUpdateUserInterests:selectedInterests];
            }
        }
        if (error) {
            NSLog(@"Error: saveEventually... %@", error);
            [user saveEventually];
        }
    }];
    
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    /*
    // Layout param
    InterestFlowLayout *layoutFlow = [[InterestFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(320,42)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(320,32)];
    
    // Show the interests
    FTInspirationViewController *rootViewController = [[FTInspirationViewController alloc] initWithCollectionViewLayout:layoutFlow];
    rootViewController.interests = selectedInterests;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    // Fetch user matches
    //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-172800];
    NSMutableArray *userPhoto = [NSMutableArray array];
    NSMutableArray *userId = [NSMutableArray array];
    NSMutableArray *userInterests = [NSMutableArray array];
    
    PFQuery *innerQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [innerQuery whereKey:kFTInterestKey containedIn:self.interests];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
    [query whereKey:@"userId" matchesKey:@"objectId" inQuery:innerQuery];
    //[query whereKey:@"createdAt" greaterThan:date];
    
    [query includeKey:kFTInterestKey];
    [query includeKey:@"userId"];
    [query setLimit:10];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            for (PFObject *user in users) {
                PFObject *obj = user[@"userId"];
                PFFile *imageFile = obj[@"userPhoto"];
                
                if(![userId containsObject:obj.objectId]){
                    [userPhoto addObject: imageFile];
                    [userId addObject: obj.objectId];
                    [userInterests addObject: obj[@"interests"]];
                }
            }
            // NOTE: I am almost certain there is a better way of doing this but because I am new and learning as I go this was
            // the solution I came up with.
            // Ideally you would want both the UserPhoto and userInterests in the same dictionary to be searchable by the common Id
            // You would then want to specify if you want the photo or the interest of the given userId. REVISIT IN THE FUTURE.
            
            rootViewController.usersToRecommendInterests = [NSDictionary dictionaryWithObjects:userInterests forKeys:userId];
            rootViewController.usersToRecommend = [NSDictionary dictionaryWithObjects:userPhoto forKeys:userId];
            rootViewController.userKeys = [rootViewController.usersToRecommend allKeys];
            
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
     
     */
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:HEADERVIEW
                                                                                     forIndexPath:indexPath];
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
        
        BOOL isFirstCell = NO;
        if(indexPath.row % 2 == 0){
            isFirstCell = YES;
        }
        
        if (isFirstCell){
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width, 0.0f, 1, cell.frame.size.height)];
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

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
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

- (void)didTapBackButtonAction:(id)sender {
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
