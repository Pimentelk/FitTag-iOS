//
//  InterestsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInterestsViewController.h"
#import "InterestCellCollectionView.h"
#import "FTInspirationViewController.h"
#import "CollectionHeaderView.h"
#import "InterestFlowLayout.h"

@interface FTInterestsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *selectedInterests;
}
@end

@implementation FTInterestsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init Selected Interests Array
    selectedInterests = [NSMutableArray array];
    
    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_image_03"]]];
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fittag_logo"]]];
    
    // Data view
    [self.collectionView registerClass:[InterestCellCollectionView class] forCellWithReuseIdentifier:@"DataCell"];
    [self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interests"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            
            NSMutableArray *tmpInterests = [NSMutableArray array];
            
            for (PFObject *object in objects) {
                
                if(object[@"interest"]){
                    [tmpInterests addObject: object[@"interest"]];
                }
            }
            
            [self setInterests:tmpInterests];
            [self.collectionView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // Collection view
    [self.collectionView setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.collectionView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    // Toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
    
    // Label
    UILabel *nextMessage = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 280.0f, 30.0f)];
    nextMessage.numberOfLines = 0;
    nextMessage.text = @"SELECT AT LEAST 3 INTERESTS";
    nextMessage.backgroundColor = [UIColor clearColor];
    
    // Next button
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4.0f, 34.0f, 37.0f)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(submitUserInterests) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:nextMessage];
    [self.navigationController.toolbar addSubview:nextButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"InterestsViewController::didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

#pragma mark - InterestViewController

- (void)submitUserInterests
{
    if( selectedInterests.count < 3){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil)
                                    message:NSLocalizedString(@"Make sure you select 3 interests!", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"Selected Interests: %@",selectedInterests);
        
        PFUser *user = [PFUser currentUser];
        if(user){
            
            // Save selected interests here...
            user[@"interests"] = selectedInterests;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Error: saveEventually... %@", error);
                    [user saveEventually];
                } else {
                    NSLog(@"Saving... %@", user);
                }
            }];
            
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

            PFQuery *innerQuery = [PFQuery queryWithClassName:@"_User"];
            [innerQuery whereKey:@"interests" containedIn:self.interests];

            PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
            [query whereKey:@"userId" matchesKey:@"objectId" inQuery:innerQuery];
            //[query whereKey:@"createdAt" greaterThan:date];
            
            [query includeKey:@"interests"];
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
            
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Error", nil)
                                        message:NSLocalizedString(@"Could not save interests!", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:@"HeaderView"
                                                                                     forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.interests.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InterestCellCollectionView *cell = (InterestCellCollectionView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DataCell" forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[InterestCellCollectionView class]]) {
        cell.backgroundColor = [UIColor clearColor];
        cell.interestLabel.text = self.interests[indexPath.row];
        
        BOOL isFirstCell = NO;
        
        if(indexPath.row % 2 == 0){
            isFirstCell = YES;
        }
        
        if(isFirstCell){
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width, 0.0f, 1, cell.frame.size.height)];
            divider.backgroundColor = [UIColor lightGrayColor];
            [cell addSubview:divider];
        }
    }
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    InterestCellCollectionView *cell = (InterestCellCollectionView *)[collectionView cellForItemAtIndexPath:indexPath];
    if([cell isSelectedToggle]){
        [selectedInterests addObject:self.interests[indexPath.row]];
    } else {
        [selectedInterests removeObject:self.interests[indexPath.row]];
    }
}
@end
