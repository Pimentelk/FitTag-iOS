//
//  FindFriendsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "CollectionHeaderView.h"
#import "FeedCollectionViewFlowLayout.h"
#import "FTFeedViewController.h"
#import "FTNavigationBar.h"
#import "FTToolBar.h"

@interface FindFriendsViewController ()

@end

@implementation FindFriendsViewController

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

    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_image_05"]]];
    [self.collectionView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fittag_logo"]]];

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
    nextMessage.text = @"YOUR JOURNEY STARTS HERE";
    nextMessage.backgroundColor = [UIColor clearColor];
    
    // Next button
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4.0f, 34.0f, 37.0f)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(submitUserInspiration) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:nextMessage];
    [self.navigationController.toolbar addSubview:nextButton];
}

- (void)submitUserInspiration
{
    FeedCollectionViewFlowLayout *layoutFlow = [[FeedCollectionViewFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(320,320)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
    
    // Show the interests
    //FeedViewController *rootViewController = [[FeedViewController alloc] initWithCollectionViewLayout:layoutFlow];
    FTFeedViewController *rootViewController = [[FTFeedViewController alloc] initWithClassName:@"Tbl_follower"];
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class] toolbarClass:[FTToolBar class]];
    [navController setViewControllers:@[rootViewController] animated:NO];
    
    // Present the Interests View Controller
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        [headerView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)];
        [headerView.messageHeader setText:@"YOUR FRIENDS ALREADY ON FITTAG"];
        [headerView.messageText setText:@""];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}


@end
