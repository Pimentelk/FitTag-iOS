//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTEditPhotoViewController (){
    CLLocationManager *locationManager;
}
@end

@interface FTEditPhotoViewController()
@property (nonatomic) CGFloat locationLabelOriginalY;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoURL;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) NSInteger scrollViewHeight;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) NSString *postLocation;
@property (nonatomic, strong) FTPostDetailsFooterView *postDetailsFooterView;
@property (nonatomic, strong) UISwitch *shareLocationSwitch;
@property UIScrollView *originalScrollView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) FTSuggestionTableView *suggestionTableView;
@property (nonatomic, strong) PFObject *place;
@end

@implementation FTEditPhotoViewController
@synthesize postDetailsFooterView;
@synthesize scrollView;
@synthesize image;
@synthesize commentTextView;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
//@synthesize tagTextField;
@synthesize scrollViewHeight;
@synthesize shareLocationSwitch;
@synthesize locationLabelOriginalY;
@synthesize originalScrollView;
@synthesize doneButton;
@synthesize suggestionTableView;
@synthesize place;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [photoImageView setBackgroundColor:[UIColor whiteColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:CONTENTMODE];
    [photoImageView setClipsToBounds:YES];
    
    [self.scrollView addSubview:photoImageView];
 
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    self.postDetailsFooterView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextView = postDetailsFooterView.commentView;
    self.shareLocationSwitch = postDetailsFooterView.shareLocationSwitch;
    
    self.commentTextView.delegate = self;
    self.postDetailsFooterView.delegate = self;
    
    [self.scrollView addSubview:postDetailsFooterView];
    
    scrollViewHeight = photoImageView.frame.origin.y + photoImageView.frame.size.height + postDetailsFooterView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, scrollViewHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start Updating Location
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [[self locationManager] startUpdatingLocation];
    
    // NavigationBar & ToolBar
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.toolbar setHidden:YES];
    [self.navigationItem setTitle:NAVIGATION_TITLE_CAM];
    [self.navigationItem setHidesBackButton:NO];
    
    // Override the back idnicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(hideCameraView:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self shouldUploadImage:self.image];
    
    // Setup the suggestions view
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    originalScrollView = self.scrollView;
    
    // Done button
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButtonAction:)];
    [doneButton setTintColor:[UIColor whiteColor]];
    
    suggestionTableView = [[FTSuggestionTableView alloc] initWithFrame:CGRectMake(0, 150, 320, 150) style:UITableViewStylePlain];
    [suggestionTableView setBackgroundColor:[UIColor whiteColor]];
    [suggestionTableView setSuggestionDelegate:self];
    [suggestionTableView setAlpha:0];
    [self.navigationItem setRightBarButtonItem:nil];
    
    [self.view addSubview:suggestionTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_EDIT_PHOTO];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - FTSuggestionTableViewDelegate

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView
           didSelectHashtag:(NSString *)hashtag
             completeString:(NSString *)completeString {
    
    if (hashtag) {
        //NSString *hashtagString = [@"#" stringByAppendingString:hashtag];
        NSString *replaceString = [commentTextView.text stringByReplacingOccurrencesOfString:completeString withString:hashtag];
        [commentTextView setText:replaceString];
    }
}

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView
              didSelectUser:(PFUser *)user
             completeString:(NSString *)completeString {
    
    if ([user objectForKey:kFTUserDisplayNameKey]) {
        NSString *displayname = [user objectForKey:kFTUserDisplayNameKey];
        //NSString *mentionString = [@"@" stringByAppendingString:displayname];
        NSString *replaceString = [commentTextView.text stringByReplacingOccurrencesOfString:completeString withString:displayname];
        [commentTextView setText:replaceString];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        commentTextView.textColor = [UIColor lightGrayColor];
        commentTextView.text = CAPTION_TEXT;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([commentTextView.text isEqualToString:CAPTION_TEXT]) {
        commentTextView.text = EMPTY_STRING;
        commentTextView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect tableViewRect = CGRectMake(0, self.postDetailsFooterView.frame.origin.y-210, self.scrollView.frame.size.width, 210);
    [suggestionTableView setFrame:tableViewRect];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [self.view bringSubviewToFront:suggestionTableView];
    
    NSArray *mentionRanges = [FTUtility rangesOfMentionsInString:textView.text];
    NSArray *hashtagRanges = [FTUtility rangesOfHashtagsInString:textView.text];
    
    NSTextCheckingResult *currentMention;
    NSTextCheckingResult *currentHashtag;
    
    if (mentionRanges.count > 0) {
        for (int i = 0; i < [mentionRanges count]; i++) {
            
            NSTextCheckingResult *mention = [mentionRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingMentionRange = NSMakeRange(mention.range.location, mention.range.length + 1);
            
            if (NSLocationInRange(range.location, currentlyTypingMentionRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentMention = mention;
            }
        }
    }
    
    if (hashtagRanges.count > 0) {
        for (int i = 0; i < [hashtagRanges count]; i++) {
            
            NSTextCheckingResult *hashtag = [hashtagRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingHashtagRange = NSMakeRange(hashtag.range.location, hashtag.range.length + 1);
            
            if (NSLocationInRange(range.location, currentlyTypingHashtagRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentHashtag = hashtag;
            }
        }
    }
    
    if (currentMention){
        
        // Disable scrolling to prevent interfearance with controller
        [self.scrollView setScrollEnabled:NO];
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_USERS];
        
        NSString *string = [[textView.text substringWithRange:currentMention.range] stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING];
        string = [string stringByAppendingString:text];
        
        if (text.length > 0) {
            
            //NSLog(@"text:%@",text);
            //NSLog(@"string:%@",string);
            //NSLog(@"textField.text:%@",textField.text);
            
            [suggestionTableView updateSuggestionWithText:string AndType:SUGGESTION_TYPE_USERS];
        }
        
    } else if (currentHashtag){
        
        // Disable scrolling to prevent interfearance with controller
        [self.scrollView setScrollEnabled:NO];
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_HASHTAGS];
        
        NSString *string = [[textView.text substringWithRange:currentHashtag.range] stringByReplacingOccurrencesOfString:@"#" withString:EMPTY_STRING];
        string = [string stringByAppendingString:text];
        
        if (text.length > 0) {
            [suggestionTableView updateSuggestionWithText:string AndType:SUGGESTION_TYPE_HASHTAGS];
        }
        
    } else {
        //NSLog(@"Not showing auto complete...");
        [self.scrollView setScrollEnabled:YES];
        
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:0];
        }];
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextView resignFirstResponder];
    [suggestionTableView setAlpha:0];
    
    [self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - FTPlacesViewControllerDelegate

- (void)placesViewController:(FTPlacesViewController *)placesViewController
           didTapSelectPlace:(PFObject *)aPlace {

    place = aPlace;
    
    //NSLog(@"placesViewController:didTapSelectPlace:%@",place);
    
    if ([place objectForKey:kFTPlaceNameKey]) {
        NSLog(@"place selected:%@",[place objectForKey:kFTPlaceNameKey]);
        [postDetailsFooterView.shareLocationLabel setText:[place objectForKey:kFTPlaceNameKey]];
    }
}

- (void)placesViewController:(FTPlacesViewController *)placesViewController
          didTapCancelButton:(UIButton *)button {
    
    place = nil;
}

#pragma mark - FTPhotoPostDetailsFooterViewDelegate

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
 didChangeShareLocationSwitch:(UISwitch *)lever {
    
    FTPlacesViewController *placesTableViewController = [[FTPlacesViewController alloc] init];
    [placesTableViewController setGeoPoint:self.geoPoint];
    [placesTableViewController setDelegate:self];
    
    [self.navigationController pushViewController:placesTableViewController animated:YES];
}

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
    didTapFacebookShareButton:(UIButton *)button {
    // Facebook button is on
}

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
     didTapTwitterShareButton:(UIButton *)button {
    // Twitter button is on
}

#pragma mark - ()

- (void)incrementUserPostCount {
    // Increment user post count
    PFUser *user = [PFUser currentUser];
    [user incrementKey:kFTUserPostCountKey byAmount:[NSNumber numberWithInt:1]];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            long int postCount = (long)[[user objectForKey:kFTUserPostCountKey] integerValue];
            NSLog(@"postCount %ld",postCount);
            
            NSNumber *rewardCount = [NSNumber numberWithUnsignedInteger:(postCount / 10)];
            NSLog(@"rewardCount %@",rewardCount);
            
            [user setValue:rewardCount forKey:kFTUserRewardsEarnedKey];
            [user saveInBackground];
        }
    }];
}

- (void)hideCameraView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:CONTENTMODE
                                                          bounds:CGSizeMake(640, 640)
                                            interpolationQuality:kCGInterpolationHigh];
    
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f
                                    transparentBorder:0.0f
                                         cornerRadius:10.0f
                                 interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
    self.thumbnailFile = [PFFile fileWithName:@"thumbnail.png" data:imageData];
    
    if ([PFUser currentUser]) {
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
    
        [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                
                    if (error) {
                        NSLog(@"self.thumbnailFile saveInBackgroundWithBlock: %@", error);
                    }
                }];
            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }
        
            if (error) {
                NSLog(@"self.photoFile saveInBackgroundWithBlock: %@", error);
            }
        }];
    }
    
    return YES;
}

- (void)didTapDoneButtonAction:(id)sender
{
    [self.scrollView setScrollEnabled:YES];
    
    [commentTextView resignFirstResponder];
    [suggestionTableView setAlpha:0];
    
    [self.navigationItem setRightBarButtonItem:nil];
    
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,scrollViewHeight);
    
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

#pragma mark - NSKeyboardWillShow

- (void)keyboardWillShow:(NSNotification *)note {
    
    [self.scrollView setScrollEnabled:NO];
    
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = originalScrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = originalScrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    
    scrollViewContentOffset.y = 0;
    scrollViewContentOffset.y += keyboardFrameEnd.size.height - postDetailsFooterView.frame.size.height + commentTextView.frame.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:NO];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [self.scrollView setScrollEnabled:YES];
    
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,scrollViewHeight);
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
       didTapSubmitPostButton:(UIButton *)button {
    
    // Make sure there were no errors creating the image files
    if (!self.photoFile || !self.thumbnailFile) {
        
        [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Dismiss", nil] show];
        
        return;
    }
    
    if ([PFUser currentUser])
    {
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
        if (trimmedComment.length > 0 && ![trimmedComment isEqualToString:CAPTION_TEXT])
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kFTEditPostViewControllerUserInfoCommentKey,nil];
        }
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile) {
            
            [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Dismiss", nil] show];
            
            return;
        }
        
        // both files have finished uploading
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[FTUtility extractHashtagsFromText:self.commentTextView.text]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[FTUtility extractMentionsFromText:self.commentTextView.text]];
        
        // create a photo object
        PFObject *photo = [PFObject objectWithClassName:kFTPostClassKey];
        [photo setObject:[PFUser currentUser] forKey:kFTPostUserKey];
        [photo setObject:self.photoFile forKey:kFTPostImageKey];
        [photo setObject:self.thumbnailFile forKey:kFTPostThumbnailKey];
        [photo setObject:kFTPostImageKey forKey:kFTPostTypeKey];
        [photo setObject:hashtags forKey:kFTPostHashTagKey];
        [photo setObject:mentions forKey:kFTPostMentionKey];

        if (place) {
            [photo setObject:place forKey:kFTPostPlaceKey];
        }
        
        NSString *description = EMPTY_STRING;
        
        //NSLog(@"Posting photo...");
        
        // userInfo might contain any caption which might have been posted by the uploader
        if (userInfo) {
            NSString *commentText = [userInfo objectForKey:kFTEditPostViewControllerUserInfoCommentKey];
            
            if (commentText && commentText.length > 0) {
                // create and save photo caption
                //NSLog(@"photo caption");
                [photo setObject:commentText forKey:kFTPostCaptionKey];
                description = commentText;
            }
        }
        
        if ([self.shareLocationSwitch isOn]) {
            if (self.geoPoint) {
                [photo setObject:self.geoPoint forKey:kFTPostLocationKey];
            }
        }
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
    
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
    
        // Save the Photo PFObject
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            
                [[FTCache sharedCache] setAttributesForPost:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];            
                [self incrementUserPostCount];
                
                //NSLog(@"photo:%@",photo.objectId);
                NSString *link = [NSString stringWithFormat:@"http://fittag.com/viewer.php?pid=%@",photo.objectId];
                
                PFFile *caption = nil;
                if ([photo objectForKey:kFTPostImageKey]) {
                    caption = [photo objectForKey:kFTPostImageKey];
                }
                
                // If facebook icon selected, post to facebook
                if ([self.postDetailsFooterView.facebookButton isSelected]) {
                    if (caption.url) {
                        [FTUtility shareCapturedMomentOnFacebook:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                  @"Captured Healthy Moment", @"name",
                                                                  @"Healthy moment was shared via #FitTag.", @"caption",
                                                                  description, @"description",
                                                                  link, @"link",
                                                                  caption.url, @"picture", nil]];
                    }
                }
                
                // If twitter icon selected, update twitter status
                if ([self.postDetailsFooterView.twitterButton isSelected]) {
                    NSString *status = [NSString stringWithFormat:@"Captured a healthy moment via #FitTag http://fittag.com/viewer.php?pid=%@",photo.objectId];
                    [FTUtility shareCapturedMomentOnTwitter:status];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification object:photo];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
    
        // Dismiss this screen
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];         
        
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
    //NSLog(@"(CLLocationManager *)locationManager");
    if (locationManager != nil) {
        return locationManager;
    }
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    postDetailsFooterView.locationTextField.text = @"Please visit privacy settings to enable location tracking.";
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations %@",locations);
    [locationManager stopUpdatingLocation];
    if ([PFUser currentUser]) {
        CLLocation *location = [locations lastObject];
        //NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
        self.geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                               longitude:location.coordinate.longitude];
        
        // Set location
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *placemark in placemarks) {
                //NSLog(@"City: %@",[placemark locality]);
                //NSLog(@"State: %@",[placemark administrativeArea]);
                self.postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                if (postDetailsFooterView) {
                    //postDetailsFooterView.locationTextField.text = self.postLocation;
                }
            }
        }];
    }
}

@end

