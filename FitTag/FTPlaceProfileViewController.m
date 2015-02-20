//
//  FTPlaceProfileViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 2/3/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTPlaceProfileViewController.h"
#import "FTUserProfileViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTViewFriendsViewController.h"
#import "FTSearchViewController.h"

@interface FTPlaceProfileViewController () <FTBusinessProfileHeaderViewDelegate>
@property (nonatomic, strong) MPMoviePlayerViewController *mpViewController;
@end

@implementation FTPlaceProfileViewController
@synthesize contact;
@synthesize mpViewController;

/*


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    NSString *content = [self.user objectForKey:kFTUserBioKey];
    NSString *website = [self.user objectForKey:kFTUserWebsiteKey];
    
    if (website) {
        content = [NSString stringWithFormat:@"%@\n%@",content,[self.user objectForKey:kFTUserWebsiteKey]];
    }
    
    CGFloat height = [FTUtility findHeightForText:content havingWidth:self.view.frame.size.width AndFont:SYSTEMFONTBOLD(14)];
    CGSize headerSize = CGSizeMake(self.view.frame.size.width, height + PROFILE_HEADER_VIEW_HEIGHT + 15);
    
    return headerSize;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Set the buttons color to red
    [self.navigationController.toolbar setBarTintColor:FT_RED];
    [self.navigationController.toolbar setTintColor:[UIColor whiteColor]];
    [self.navigationController.toolbar setTranslucent:YES];
    
    // Navigation back button
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    [backbutton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backbutton setStyle:UIBarButtonItemStylePlain];
    [backbutton setTarget:self];
    [backbutton setAction:@selector(didTapBackButtonAction:)];
    [backbutton setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backbutton];
}

- (void)setContact:(PFUser *)aContact {
    
    contact = aContact;
    
    if (self.contact) {
        
        [self.contact fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                CGSize size = self.view.frame.size;
                
                NSString *content = [self.contact objectForKey:kFTUserBioKey];
                NSString *website = [self.contact objectForKey:kFTUserWebsiteKey];
                
                if (website) {
                    content = [NSString stringWithFormat:@"%@\n%@",content,[self.contact objectForKey:kFTUserWebsiteKey]];
                }
                
                CGRect headerRect = CGRectMake(0, 0, 0, 0);
                
                CGFloat height = [FTUtility findHeightForText:content havingWidth:size.width AndFont:SYSTEMFONTBOLD(14)];
                CGSize headerSize = CGSizeMake(size.width, height + PROFILE_HEADER_VIEW_HEIGHT_BUSINESS + 15);
                
                headerRect.size = headerSize;
                
                FTBusinessProfileHeaderView *profileHeaderView = [[FTBusinessProfileHeaderView alloc] initWithFrame:headerRect];
                [profileHeaderView setBusiness:self.contact];
                [profileHeaderView setDelegate:self];
                [profileHeaderView fetchBusinessProfileData: self.contact];
                
                self.tableView.tableHeaderView = profileHeaderView;
                
                [self.tableView setNeedsDisplay];
            
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

#pragma mark - PFQueryTableViewController

// Query for posts by the bussiness or tagged to the business
- (PFQuery *)queryForTable {
    
    //NSLog(@"kFTUserDisplayNameKey:%@",[self.contact objectForKey:kFTUserDisplayNameKey]);
    
    if (self.contact) {
        
        // posts of type image, video, or gallery
        // posts that were authored by the place contact
        PFQuery *postFromContactQuery = [PFQuery queryWithClassName:kFTPostClassKey];
        [postFromContactQuery whereKey:kFTPostTypeKey containedIn:@[ kFTPostTypeImage, kFTPostTypeVideo, kFTPostTypeGallery ]];
        [postFromContactQuery whereKey:kFTPostUserKey equalTo:self.contact];
        
        /***** * *****/
        
        // check for places with contact key values
        // checks for places where contact key value is
        // equal to the current business being viewed
        PFQuery *placeQuery = [PFQuery queryWithClassName:kFTPlaceClassKey];
        [placeQuery whereKey:kFTPlaceContactKey equalTo:self.contact];
        
        // Posts that share a location
        PFQuery *postFromLocationQuery = [PFQuery queryWithClassName:kFTPostClassKey];
        [postFromLocationQuery whereKey:kFTPostTypeKey containedIn:@[ kFTPostTypeImage, kFTPostTypeVideo, kFTPostTypeGallery ]];
        [postFromLocationQuery whereKey:kFTPostPlaceKey matchesQuery:placeQuery];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[ postFromContactQuery, postFromLocationQuery ]];
        [query includeKey:kFTPostUserKey];
        [query includeKey:kFTPostPlaceKey];
        [query orderByDescending:@"createdAt"];
        
        return query;
        
    } else {
     
        // Posts that share a location
        PFQuery *query = [PFQuery queryWithClassName:kFTPostClassKey];
        [query whereKey:kFTPostTypeKey containedIn:@[ kFTPostTypeImage, kFTPostTypeVideo, kFTPostTypeGallery ]];
        [query whereKey:kFTPostPlaceKey equalTo:self.place];
        [query includeKey:kFTPostUserKey];
        [query includeKey:kFTPostPlaceKey];
        [query orderByDescending:@"createdAt"];
        
        return query;
    }
}

#pragma mark 

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FTBusinessProfileHeaderViewDelegate

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                    didTapHashtag:(NSString *)Hashtag {
    
    FTSearchViewController *searchViewController = [[FTSearchViewController alloc] init];
    [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
    [searchViewController setSearchString:Hashtag];
    
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                didTapUserMention:(NSString *)mention {
    
    NSString *lowercaseStringWithoutSymbols = [FTUtility getLowercaseStringWithoutSymbols:mention];
    
    //****** Display Name ********//
    PFQuery *queryStringMatchHandle = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryStringMatchHandle whereKeyExists:kFTUserDisplayNameKey];
    [queryStringMatchHandle whereKey:kFTUserDisplayNameKey equalTo:lowercaseStringWithoutSymbols];
    [queryStringMatchHandle findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            
            //NSLog(@"users:%@",users);
            //NSLog(@"users.count:%lu",(unsigned long)users.count);
            
            if (users.count == 1) {
                
                PFUser *mentionedUser = [users objectAtIndex:0];
                //NSLog(@"mentionedUser:%@",mentionedUser);
                
                if ([mentionedUser objectForKey:kFTUserTypeBusiness]) {
                    // Business profile
                    FTPlaceProfileViewController *placeViewController = [[FTPlaceProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [placeViewController setContact:mentionedUser];
                    
                    [self.navigationController pushViewController:placeViewController animated:YES];
                } else {
                    
                    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
                    [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
                    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                    [flowLayout setMinimumInteritemSpacing:0];
                    [flowLayout setMinimumLineSpacing:0];
                    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
                    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
                    
                    FTUserProfileViewController *userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
                    [userProfileViewController setUser:mentionedUser];
                    [self.navigationController pushViewController:userProfileViewController animated:YES];
                }
                
            } else {
                
                FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
                [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
                [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
                [followFriendsViewController querySearchForUser];
                
                [self.navigationController pushViewController:followFriendsViewController animated:YES];
            }
        }
    }];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                       didTapLink:(NSString *)link {
    
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
             didTapGetThereButton:(UIButton *)button {
    
    //NSLog(@"didTapGetThereButton:");
    //NSLog(@"kFTUserLocationKey:%@",[self.business objectForKey:kFTUserLocationKey]);
    
    if ([self.contact objectForKey:kFTUserLocationKey]) {
        
        PFGeoPoint *geoPoint = [self.contact objectForKey:kFTUserLocationKey];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                
                for (CLPlacemark *placemark in placemarks) {
                    
                    NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@",[placemark thoroughfare],[placemark locality],[placemark administrativeArea],[placemark country]];
                    
                    if (address) {
                        
                        NSString *currentLocation = @"Current Location";
                        NSString *url = [NSString stringWithFormat:@"maps://?saddr=%@&daddr=%@&directionsmode=driving",
                                         [currentLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                         [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        BOOL opened = [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
                        
                        if (!opened) {
                            [[[UIAlertView alloc]initWithTitle:@"Message"
                                                       message:@"Something went wrong. Could not open your local maps GPS."
                                                      delegate:nil
                                             cancelButtonTitle:@"ok"
                                             otherButtonTitles:nil, nil] show];
                        }
                        
                    } else {
                        [[[UIAlertView alloc]initWithTitle:@"Message"
                                                   message:@"Location is not available."
                                                  delegate:nil
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil, nil] show];
                    }
                }
            }
            
            if (error) {
                NSLog(@"error:%@",error);
                [[[UIAlertView alloc]initWithTitle:@"Message"
                                           message:@"Location is not available."
                                          delegate:nil
                                 cancelButtonTitle:@"ok"
                                 otherButtonTitles:nil, nil] show];
            }
        }];
    } else {
        
        [[[UIAlertView alloc]initWithTitle:@"Message"
                                   message:@"Location is not available."
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil, nil] show];
    }
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
                 didTapCallButton:(UIButton *)button {
    
    NSString *phNo = [self.contact objectForKey:kFTUserPhoneKey];
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
    
    if ([self.contact objectForKey:kFTUserPromoVideo]) {
        PFFile *videoFile = [self.contact objectForKey:kFTUserPromoVideo];
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
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:MAIL_BUSINESS_SUBJECT];
        //[mailer setToRecipients:[NSArray arrayWithObjects:MAIL_FEEDBACK_EMAIL, nil]];
        if ([self.contact objectForKey:kFTUserEmailKey]) {
            [mailer setToRecipients:[NSArray arrayWithObjects:[self.contact objectForKey:kFTUserEmailKey], nil]];
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
             didTapSettingsButton:(id)sender {
    
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
            didTapFollowersButton:(id)sender {
    
    FTViewFriendsViewController *viewFriendsViewController = [[FTViewFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    [viewFriendsViewController setUser:self.contact];
    [viewFriendsViewController queryForFollowers];
    [self.navigationController pushViewController:viewFriendsViewController animated:YES];
}

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView
            didTapFollowingButton:(id)sender {
    
    FTViewFriendsViewController *viewFriendsViewController = [[FTViewFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    [viewFriendsViewController setUser:self.contact];
    [viewFriendsViewController queryForFollowing];
    [self.navigationController pushViewController:viewFriendsViewController animated:YES];
}

@end
