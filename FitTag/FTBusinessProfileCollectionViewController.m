//
//  ProfileViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileCollectionViewController.h"
#import "FTUserProfileCollectionViewCell.h"
#import "FTPostDetailsViewController.h"
#import "FTCamViewController.h"
//#import "MBProgressHUD.h"
#import "FTMapViewController.h"

@interface FTBusinessProfileCollectionViewController() <UICollectionViewDataSource,UICollectionViewDelegate> {
    NSString *cellTab;
}
@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) MFMailComposeViewController *mailer;
@end

@implementation FTBusinessProfileCollectionViewController
@synthesize business;
@synthesize mailer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.business) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    cellTab = @"SMALLGRID"; // SMALLGRIDE | FULLGRID | BUSINESSES | TAGGED
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:[business objectForKey:kFTUserDisplayNameKey]];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *backIndicatorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(didTapBackButtonAction:)];
    
    UIBarButtonItem *loadCameraButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(loadCameraAction:)];
    
    [backIndicatorButtonItem setTintColor:[UIColor whiteColor]];
    [loadCameraButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backIndicatorButtonItem];
    [self.navigationItem setRightBarButtonItem:loadCameraButtonItem];
    
    // Set Background
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Data view
    [self.collectionView registerClass:[FTUserProfileCollectionViewCell class]
            forCellWithReuseIdentifier:@"DataCell"];
    
    [self.collectionView registerClass:[FTBusinessProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
    
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    [self queryForTable:self.business];
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
        FTBusinessProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                 withReuseIdentifier:@"HeaderView"
                                                                                        forIndexPath:indexPath];
        
        [headerView setDelegate: self];
        [headerView setBusiness:self.business];
        [headerView fetchBusinessProfileData: self.business];
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
        [flowLayout setHeaderReferenceSize:CGSizeMake(320,335)];
        
        PFUser *followedBusiness = self.cells[indexPath.row];
        NSLog(@"FTUserProfileCollectionViewController:: followedBusiness: %@",followedBusiness);
        if (followedBusiness) {
            FTBusinessProfileCollectionViewController *businessProfileViewController = [[FTBusinessProfileCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
            [businessProfileViewController setBusiness:followedBusiness];
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
            PFUser *followedBusiness = self.cells[indexPath.row];
            [cell setUser:followedBusiness];
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

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)mailComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        //case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            //break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation Bar

- (void)loadCameraAction:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:camViewController animated:YES];
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - FTBusinessProfileCollectionHeaderViewDelegate

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                       didTapGetThereButton:(UIButton *)button {
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:40.7409816 longitude:-74.03021560000002];
    [mapViewController setInitialLocation:location];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                           didTapCallButton:(UIButton *)button {
    
    
    NSString *phNo = @"+8638525694";
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
        NSLog(@"phone btn touch %@", phNo);
    } else  {
        [[[UIAlertView alloc]initWithTitle:@"Alert"
                                   message:@"Call facility is not available!!!"
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil, nil] show];
    }
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                          didTapVideoButton:(UIButton *)button {
    
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                          didTapEmailButton:(UIButton *)button {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        mailer = [[MFMailComposeViewController alloc] init];
        self.mailer.mailComposeDelegate = self;
        [mailer setSubject:@"A Message from MobileTuts+"];
        [mailer setToRecipients:[NSArray arrayWithObjects:@"de56ep@gmail.com", nil]];
        /*
        NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@<span class="skimlinks-unlinked">example.com</span>", @"secondMail@<span class="skimlinks-unlinked">example.com</span>", nil];
        */
        
        //[mailer setToRecipients:@"de56ep@gmail.com"];
        
        //UIImage *myImage = [UIImage imageNamed:@"<span class="skimlinks-unlinked">mobiletuts-logo.png</span>"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        
        NSString *emailBody = @"Message body here";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                         didTapFollowButton:(UIButton *)button {
    /*
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureUnfollowButton];
    */
    
    // check if the currentUser is following this user
    if (![[self.business objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kFTActivityClassKey];
        [queryIsFollowing whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
        [queryIsFollowing whereKey:kFTActivityToUserKey equalTo:self.business];
        [queryIsFollowing whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                //self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [FTUtility followUserEventually:self.business block:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            
                        }
                    }];
                } else {
                    [FTUtility unfollowUserEventually:self.business block:^(NSError *error) {
                        if (!error) {
                            
                        }
                    }];
                }
            }
        }];
    } else {
        NSLog(@"Can not follow yourself.");
    }
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                           didTapGridButton:(UIButton *)button {
    cellTab = @"SMALLGRID";
    [self queryForTable:self.business];
}

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
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
                PFUser *followedBusiness = [object objectForKey:kFTActivityToUserKey];
                if ([[followedBusiness objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                    [businesses addObject:followedBusiness];
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

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                         didTapTaggedButton:(UIButton *)button {
    
    cellTab = @"TAGGED"; // kFTUserTypeBusiness | SMALLGRID | FULLGRID | TAGGED
    NSMutableString *displayName = [[self.business objectForKey:kFTUserDisplayNameKey] mutableCopy];
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

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView
                       didTapSettingsButton:(id)sender {
    
}

@end
