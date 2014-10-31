//
//  InspirationViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/3/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInspirationViewController.h"
#import "CollectionHeaderView.h"
#import "InspirationCellCollectionView.h"
#import "FTFindFriendsViewController.h"

@implementation FTInspirationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_image_07"]]];
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fittag_logo"]]];
    
    // Register Cell
    [self.collectionView registerClass:[InspirationCellCollectionView class] forCellWithReuseIdentifier:@"MemberCell"];
    
    // Register header
    [self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
        
    // Set collectionview frame
    [self.collectionView setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.collectionView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    
    // Toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
    
    // Label
    UILabel *nextMessage = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 280.0f, 30.0f)];
    nextMessage.numberOfLines = 0;
    nextMessage.text = @"SELECT AT LEAST 5 FOLLOWERS";
    nextMessage.backgroundColor = [UIColor clearColor];
    
    // Next button
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4.0f, 34.0f, 37.0f)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(submitUserInspiration:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:nextMessage];
    [self.navigationController.toolbar addSubview:nextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INSPIRATION];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)submitUserInspiration:(id)sender{
    // Layout param
    
    // Show the interests
    //FindFriendsViewController *findFriendsViewContoller = [[FindFriendsViewController alloc] initWithCollectionViewLayout:layoutFlow];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:findFriendsViewContoller];
    //[self presentViewController:navController animated:YES completion:NULL];
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        [headerView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)];
        [headerView.messageHeader setText:@"FIND THE PEOPLE THAT INSPIRE YOU"];
        [headerView.messageText setText:EMPTY_STRING];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    
    return reusableview;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.usersToRecommend.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    InspirationCellCollectionView *cell = (InspirationCellCollectionView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MemberCell" forIndexPath:indexPath];
    NSMutableArray *sharedInterests = [self intersect:self.interests withUser:[self.usersToRecommendInterests objectForKey:self.userKeys[indexPath.row]]];
    NSString *interest = [[sharedInterests componentsJoinedByString:@"\r\n"] uppercaseString];

    NSLog(@"Matching interests: %@",interest);
    if ([cell isKindOfClass:[InspirationCellCollectionView class]]) {
        cell.backgroundColor = [UIColor clearColor];
        cell.message.text = @"BECAUSE YOU HAVE INTEREST IN ";
        cell.messageInterests.text = interest;
        cell.imageFile = [self.usersToRecommend objectForKey:self.userKeys[indexPath.row]];
    }
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // When item is selected do something
    InspirationCellCollectionView *cell = (InspirationCellCollectionView *)[collectionView cellForItemAtIndexPath:indexPath];
    if(![cell isSelectedToggle]){
        NSLog(@"Item selected");
        cell.isSelectedToggle = YES;
        cell.image = [UIImage imageNamed:@"user_selected"];
    } else {
        cell.isSelectedToggle = NO;
        cell.imageFile = [self.usersToRecommend objectForKey:self.userKeys[indexPath.row]];
    }
}

-(NSMutableArray *) intersect:(NSArray*)selected withUser:(NSArray*)interests{

    NSMutableArray *sharedInterests = [@[] mutableCopy];
    for (NSObject *obj in selected)    {
        if([interests containsObject:obj] && ![sharedInterests containsObject:obj])
            [sharedInterests addObject:obj];
    }
    
    return sharedInterests;
}

@end
