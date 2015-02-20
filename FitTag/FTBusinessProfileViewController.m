//
//  ProfileViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileViewController.h"
#import "FTBusinessProfileHeaderView.h"
#import "FTUserProfileCollectionViewCell.h"
#import "FTPostDetailsViewController.h"
#import "FTCamViewController.h"
#import "FTMapViewController.h"
#import "FTViewFriendsViewController.h"
#import "FTUserProfileViewController.h"
#import "FTSearchViewController.h"

#define GRID_SMALL @"SMALLGRID"
#define GRID_FULL @"FULLGRID"
#define GRID_BUSINESS @"BUSINESSES"
#define GRID_TAGGED @"TAGGED"
#define REUSEABLE_IDENTIFIER_DATA @"DataCell"
#define REUSEABLE_IDENTIFIER_HEADER @"HeaderView"

@interface FTBusinessProfileViewController() <UICollectionViewDataSource,UICollectionViewDelegate,FTBusinessProfileHeaderViewDelegate> {
    NSString *cellTab;
}

@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) MFMailComposeViewController *mailer;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) FTViewFriendsViewController *viewFriendsViewController;
@property (nonatomic, strong) MPMoviePlayerViewController *mpViewController;
@property (nonatomic, strong) FTBusinessProfileViewController *businessProfileViewController;
@property (nonatomic, strong) FTUserProfileViewController *userProfileViewController;
@property (nonatomic, strong) FTFollowFriendsViewController *followFriendsViewController;
@property (nonatomic, strong) FTSearchViewController *searchViewController;
@end

@implementation FTBusinessProfileViewController
@synthesize business;
@synthesize mailer;
@synthesize viewFriendsViewController;
@synthesize mpViewController;
@synthesize businessProfileViewController;
@synthesize userProfileViewController;
@synthesize followFriendsViewController;
@synthesize searchViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.business) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
    }
    
    cellTab = GRID_SMALL;
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:[business objectForKey:kFTUserDisplayNameKey]];
    
    UIBarButtonItem *backIndicatorButtonItem = [[UIBarButtonItem alloc] init];
    [backIndicatorButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicatorButtonItem setStyle:UIBarButtonItemStylePlain];
    [backIndicatorButtonItem setTarget:self];
    [backIndicatorButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backIndicatorButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicatorButtonItem];
    
    // Set Background
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];

    // Data view
    [self.collectionView registerClass:[FTUserProfileCollectionViewCell class]
            forCellWithReuseIdentifier:REUSEABLE_IDENTIFIER_DATA];
    
    [self.collectionView registerClass:[FTBusinessProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:REUSEABLE_IDENTIFIER_HEADER];
    
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    [self queryForTable:self.business];
    
    // initialize FTViewFriendsViewController
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    viewFriendsViewController = [[FTViewFriendsViewController alloc] init];
    [viewFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
    [viewFriendsViewController setUser:self.business];
    
    searchViewController = [[FTSearchViewController alloc] init];
    [searchViewController.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Business profile
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
    
    // Business profile
    businessProfileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [businessProfileViewController.navigationItem setLeftBarButtonItem:backIndicator];
    
    // User profile
    userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [userProfileViewController.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Show suggestions if mention not found
    followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_BUSINESS];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
                                                                                     withReuseIdentifier:REUSEABLE_IDENTIFIER_HEADER
                                                                                            forIndexPath:indexPath];
        
        [headerView setDelegate:self];
        [headerView setBusiness:self.business];
        [headerView fetchBusinessProfileData: self.business];
        reusableview = headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    NSString *content = [self.business objectForKey:kFTUserBioKey];
    NSString *website = [self.business objectForKey:kFTUserWebsiteKey];
    
    if (website) {
        content = [NSString stringWithFormat:@"%@\n%@",content,[self.business objectForKey:kFTUserWebsiteKey]];
    }
    
    CGFloat height = [FTUtility findHeightForText:content havingWidth:self.view.frame.size.width AndFont:SYSTEMFONTBOLD(14)];
    CGSize headerSize = CGSizeMake(self.view.frame.size.width, height + PROFILE_HEADER_VIEW_HEIGHT_BUSINESS + 30);
    
    return headerSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.cells.count;
}

- (void)    collectionView:(UICollectionView *)collectionView
  didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"indexpath: %ld",(long)indexPath.row);
    if ([cellTab isEqualToString:kFTUserTypeBusiness]) {
        
        PFUser *followedBusiness = self.cells[indexPath.row];
        //NSLog(@"FTUserProfileCollectionViewController:: followedBusiness: %@",followedBusiness);
        if (followedBusiness) {
            [businessProfileViewController setBusiness:followedBusiness];
            [self.navigationController pushViewController:businessProfileViewController animated:YES];
        }
        
    } else {
        FTPostDetailsViewController *postDetailView = [[FTPostDetailsViewController alloc] initWithPost:self.cells[indexPath.row] AndType:nil];
        [self.navigationController pushViewController:postDetailView animated:YES];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set up cell identifier that matches the Storyboard cell name
    static NSString *identifier = REUSEABLE_IDENTIFIER_DATA;
    FTUserProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[FTUserProfileCollectionViewCell class]]) {
        cell.backgroundColor = [UIColor clearColor];
        if ([cellTab isEqualToString:kFTUserTypeBusiness]) {
            //NSLog(@"self.cells: %@", self.cells[indexPath.row]);
            PFUser *followedBusiness = self.cells[indexPath.row];
            [cell setUser:followedBusiness];
        } else {
            PFObject *object = self.cells[indexPath.row];
            [cell setPost:object];
        }
    }
    return cell;
}

#pragma mark - Navigation Bar

- (void)loadCameraAction:(id)sender
{
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:camViewController animated:YES];
}

- (void)didTapBackButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - FTBusinessProfileHeaderViewDelegate

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                    didTapHashtag:(NSString *)Hashtag
{
    if (searchViewController)
    {
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:Hashtag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                didTapUserMention:(NSString *)mention
{
    NSString *lowercaseStringWithoutSymbols = [FTUtility getLowercaseStringWithoutSymbols:mention];
    
    //****** Display Name ********//
    PFQuery *queryStringMatchHandle = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryStringMatchHandle whereKeyExists:kFTUserDisplayNameKey];
    [queryStringMatchHandle whereKey:kFTUserDisplayNameKey equalTo:lowercaseStringWithoutSymbols];
    [queryStringMatchHandle findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error)
        {
            //NSLog(@"users:%@",users);
            //NSLog(@"users.count:%lu",(unsigned long)users.count);
            if (users.count == 1)
            {
                PFUser *mentionedUser = [users objectAtIndex:0];
                //NSLog(@"mentionedUser:%@",mentionedUser);
                
                if ([mentionedUser objectForKey:kFTUserTypeBusiness])
                {
                    [businessProfileViewController setBusiness:mentionedUser];
                    [self.navigationController pushViewController:businessProfileViewController animated:YES];
                }
                else
                {
                    [userProfileViewController setUser:mentionedUser];
                    [self.navigationController pushViewController:userProfileViewController animated:YES];
                }
            }
            else
            {
                [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
                [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
                [followFriendsViewController querySearchForUser];
                
                [self.navigationController pushViewController:followFriendsViewController animated:YES];
            }
        }
    }];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                       didTapLink:(NSString *)link
{
    // Clean the string
    NSString *cleanLink;
    cleanLink = [link lowercaseString];
    cleanLink = [cleanLink stringByReplacingOccurrencesOfString:@"www." withString:@""];
    cleanLink = [cleanLink stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    cleanLink = [NSString stringWithFormat:@"http://www.%@",cleanLink];
    
    NSURL *url = [NSURL URLWithString:cleanLink];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
             didTapGetThereButton:(UIButton *)button
{
    //NSLog(@"didTapGetThereButton:");
    //NSLog(@"kFTUserLocationKey:%@",[self.business objectForKey:kFTUserLocationKey]);
    
    if ([self.business objectForKey:kFTUserLocationKey])
    {
        PFGeoPoint *geoPoint = [self.business objectForKey:kFTUserLocationKey];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if (!error)
            {
                for (CLPlacemark *placemark in placemarks)
                {
                    NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@",[placemark thoroughfare],
                                                                                  [placemark locality],
                                                                                  [placemark administrativeArea],
                                                                                  [placemark country]];
                    
                    if (address)
                    {
                        NSString *currentLocation = @"Current Location";
                        NSString *url = [NSString stringWithFormat:@"maps://?saddr=%@&daddr=%@&directionsmode=driving",
                                         [currentLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                         [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        BOOL opened = [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
                        
                        if (!opened)
                        {
                            [[[UIAlertView alloc]initWithTitle:@"Message"
                                                       message:@"Something went wrong. Could not open your local maps GPS."
                                                      delegate:nil
                                             cancelButtonTitle:@"ok"
                                             otherButtonTitles:nil, nil] show];
                        }
                    }
                    else
                    {
                        [[[UIAlertView alloc]initWithTitle:@"Message"
                                                   message:@"Location is not available."
                                                  delegate:nil
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil, nil] show];
                    }
                }
            }
            
            if (error)
            {
                NSLog(@"error:%@",error);
                [[[UIAlertView alloc]initWithTitle:@"Message"
                                           message:@"Location is not available."
                                          delegate:nil
                                 cancelButtonTitle:@"ok"
                                 otherButtonTitles:nil, nil] show];
            }
        }];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Message"
                                   message:@"Location is not available."
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil, nil] show];
    }
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                 didTapCallButton:(UIButton *)button {
    
    NSString *phNo = [business objectForKey:kFTUserPhoneKey];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    //NSLog(@"phone btn touch %@", phNo);
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
       
    } else  {
        [[[UIAlertView alloc]initWithTitle:@"Message"
                                   message:@"Call facility is not available."
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil, nil] show];
    }
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                didTapVideoButton:(UIButton *)button {
    
    if ([business objectForKey:kFTUserPromoVideo]) {
        PFFile *videoFile = [business objectForKey:kFTUserPromoVideo];
        NSURL *videoURL = [NSURL URLWithString:videoFile.url];
        //NSLog(@"videoURL:%@",videoURL);
        
        mpViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [mpViewController.moviePlayer setScalingMode:SCALINGMODE];
        [mpViewController.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
        [mpViewController.moviePlayer setShouldAutoplay:NO];
        [mpViewController.moviePlayer prepareToPlay];
        [mpViewController.moviePlayer play];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerStateChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:mpViewController.moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadStateDidChange:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:mpViewController.moviePlayer];
        
        [self presentViewController:mpViewController animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc]initWithTitle:@"Message"
                                   message:@"No video available."
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil, nil] show];
    }
}

- (void)movieFinishedCallBack:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.mpViewController.moviePlayer];
}

- (void)loadStateDidChange:(NSNotification *)notification {
    
    //NSLog(@"loadStateDidChange: %@",notification);
    
    if (self.mpViewController.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        //NSLog(@"loadState... MPMovieLoadStatePlayable");
    }
    
    if (self.mpViewController.moviePlayer.loadState & MPMovieLoadStatePlaythroughOK) {
        //[moviePlayer.view setHidden:NO];
        
        //NSLog(@"loadState... MPMovieLoadStatePlaythroughOK");
        //[self.imageView setHidden:YES];
    }
    
    if (self.mpViewController.moviePlayer.loadState & MPMovieLoadStateStalled) {
        //NSLog(@"loadState... MPMovieLoadStateStalled");
    }
    
    if (self.mpViewController.moviePlayer.loadState & MPMovieLoadStateUnknown) {
        //NSLog(@"loadState... MPMovieLoadStateUnknown");
    }
}

- (void)moviePlayerStateChange:(NSNotification *)notification{
    
    //NSLog(@"moviePlayerStateChange: %@",notification);
    
    if (self.mpViewController.moviePlayer.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK)) {
        //NSLog(@"loadState... MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK..");
        //[self.playButton setHidden:YES];
        
        if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStatePlaying){
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
            //[UIView animateWithDuration:1 animations:^{
                //[self.mpViewController.moviePlayer.view setAlpha:1];
            //}];
        }
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStatePlaying){
        //NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStateStopped){
        //[self.playButton setHidden:NO];
        
        //NSLog(@"moviePlayer... MPMoviePlaybackStateStopped");
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStatePaused){
        //[self.playButton setHidden:NO];
        /*
        [UIView animateWithDuration:0.3 animations:^{
            [self.mpViewController.moviePlayer.view setAlpha:0];
            [self.mpViewController.moviePlayer prepareToPlay];
        }];
        */
        //NSLog(@"moviePlayer... MPMoviePlaybackStatePaused");
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStateInterrupted){
       // NSLog(@"moviePlayer... Interrupted");
        //[self.moviePlayer stop];
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStateSeekingForward){
        //NSLog(@"moviePlayer... Forward");
    }
    
    if (self.mpViewController.moviePlayer.playbackState & MPMoviePlaybackStateSeekingBackward){
        //NSLog(@"moviePlayer... Backward");
    }
}


- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                didTapEmailButton:(UIButton *)button {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        mailer = [[MFMailComposeViewController alloc] init];
        self.mailer.mailComposeDelegate = self;
        [mailer setSubject:MAIL_BUSINESS_SUBJECT];
        //[mailer setToRecipients:[NSArray arrayWithObjects:MAIL_FEEDBACK_EMAIL, nil]];
        if ([business objectForKey:kFTUserEmailKey]) {
            [mailer setToRecipients:[NSArray arrayWithObjects:[business objectForKey:kFTUserEmailKey], nil]];
        } else {
            [[[UIAlertView alloc] initWithTitle:MAIL_FAIL
                                        message:MAIL_ERROR
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
            return;
        }
        
        [mailer setMessageBody:EMPTY_STRING isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:MAIL_FAIL
                                    message:MAIL_NOT_SUPPORTED
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
    }
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                 didTapGridButton:(UIButton *)button {
    cellTab = GRID_SMALL;
    [self queryForTable:self.business];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
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

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
               didTapTaggedButton:(UIButton *)button {
    
    cellTab = GRID_TAGGED;
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

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
             didTapSettingsButton:(id)sender {
    
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
            didTapFollowersButton:(id)sender {
    
    [viewFriendsViewController queryForFollowers];
    [self.navigationController pushViewController:viewFriendsViewController animated:YES];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
            didTapFollowingButton:(id)sender {
    
    [viewFriendsViewController queryForFollowing];
    [self.navigationController pushViewController:viewFriendsViewController animated:YES];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (!error) {
        switch (result) {
            case MFMailComposeResultCancelled:
                NSLog(MAIL_CANCELLED);
                break;
            case MFMailComposeResultSaved:
                NSLog(MAIL_SAVED);
                break;
            case MFMailComposeResultSent:
                NSLog(MAIL_SENT);
                
                self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                self.hud.mode = MBProgressHUDModeText;
                self.hud.margin = 10.f;
                self.hud.yOffset = 150.f;
                self.hud.removeFromSuperViewOnHide = YES;
                self.hud.userInteractionEnabled = NO;
                self.hud.labelText = MAIL_SENT;
                [self.hud hide:YES afterDelay:3];
                
                break;
            default:
                NSLog(MAIL_FAIL);
                break;
        }
        // Remove the mail view
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"error %@",error);
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not send mail."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
    }
}
@end
