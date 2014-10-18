//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditVideoViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"

@interface FTEditVideoViewController (){
    CLLocationManager *locationManager;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSData *video;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *hashtagTextField;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier videoPostBackgroundTaskId;
@property (nonatomic, assign) NSInteger scrollViewHeight;
@property (nonatomic, strong) PFFile *videoFile;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) FTPostDetailsFooterView *postDetailsFooterView;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *videoPlaceHolderView;
@property (nonatomic, strong) NSString *postLocation;
@end

@implementation FTEditVideoViewController
@synthesize scrollView;
@synthesize commentTextField;
@synthesize fileUploadBackgroundTaskId;
@synthesize videoPostBackgroundTaskId;
@synthesize hashtagTextField;
@synthesize scrollViewHeight;
@synthesize postDetailsFooterView;
@synthesize moviePlayer;
@synthesize playButton;
@synthesize videoImageView;
@synthesize videoPlaceHolderView;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithVideo:(NSData *)aVideo {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aVideo) {
            return nil;
        }
        
        self.video = aVideo;        
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.videoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //NSLog(@"Memory warning on Edit");
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [videoImageView setBackgroundColor:[UIColor blackColor]];
    [videoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:videoImageView];
    
    // Footer view
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    footerRect.origin.y = videoImageView.frame.origin.y + videoImageView.frame.size.height;
    
    postDetailsFooterView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = postDetailsFooterView.commentField;
    self.hashtagTextField = postDetailsFooterView.hashtagTextField;
    self.commentTextField.delegate = self;
    self.hashtagTextField.delegate = self;
    postDetailsFooterView.delegate = self;
    [postDetailsFooterView.submitButton setEnabled:NO];
    [self.scrollView addSubview:postDetailsFooterView];
    scrollViewHeight = videoImageView.frame.origin.y + videoImageView.frame.size.height + postDetailsFooterView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, scrollViewHeight)];
}

- (void)didTapVideoPlayButtonAction:(UIButton *)sender{
    [moviePlayer play];
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
    [self.navigationItem setTitle: @"TAG YOUR FIT"];
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
    
    // Videoplayer background image
    videoPlaceHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [videoPlaceHolderView setBackgroundColor:[UIColor clearColor]];
    [videoPlaceHolderView setContentMode:UIViewContentModeScaleAspectFill];
    
    [videoImageView addSubview:videoPlaceHolderView];
    
    // setup the video player
    //NSLog(@"FTEditVideoViewController::Setup video...");
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setUserInteractionEnabled:NO];
    [moviePlayer.view setHidden:YES];
    
    [videoImageView addSubview:moviePlayer.view];
    [videoImageView bringSubviewToFront:moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
    
    // setup the playbutton
    float centerX = (videoImageView.frame.size.width - 60) / 2;
    float centerY = (videoImageView.frame.size.height - 60) / 2;
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setFrame:CGRectMake(centerX,centerY,60.0f,60.0f)];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setSelected:NO];
    
    [self.scrollView addSubview:self.playButton];
    [self.scrollView bringSubviewToFront:self.playButton];
    
    [self shouldUploadVideo:self.video];
}

-(void)movieFinishedCallBack:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

-(void)loadStateDidChange:(NSNotification *)notification{
    //NSLog(@"loadStateDidChange: %@",notification);
    
    if (self.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        NSLog(@"loadState... MPMovieLoadStatePlayable");
    }
    
    if (self.moviePlayer.loadState & MPMovieLoadStatePlaythroughOK) {
        NSLog(@"loadState... MPMovieLoadStatePlaythroughOK");
        [moviePlayer.view setHidden:NO];
        //[self.imageView setHidden:YES];
    }
    
    if (self.moviePlayer.loadState & MPMovieLoadStateStalled) {
        NSLog(@"loadState... MPMovieLoadStateStalled");
    }
    
    if (self.moviePlayer.loadState & MPMovieLoadStateUnknown) {
        NSLog(@"loadState... MPMovieLoadStateUnknown");
    }
}

-(void)moviePlayerStateChange:(NSNotification *)notification{
    
    //NSLog(@"moviePlayerStateChange: %@",notification);
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying){
        NSLog(@"moviePlayer... Playing");
        [self.playButton setHidden:YES];
        if (self.moviePlayer.loadState & MPMovieLoadStatePlayable) {
            NSLog(@"2 loadState... MPMovieLoadStatePlayable");
            [moviePlayer.view setHidden:NO];
            //[self.imageView setHidden:YES];
        }
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateStopped){
        NSLog(@"moviePlayer... Stopped");
        [self.playButton setHidden:NO];
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStatePaused){
        NSLog(@"moviePlayer... Paused");
        [self.playButton setHidden:NO];
        [moviePlayer.view setHidden:YES];
        //[self.imageView setHidden:NO];
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateInterrupted){
        NSLog(@"moviePlayer... Interrupted");
        //[self.moviePlayer stop];
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateSeekingForward){
        NSLog(@"moviePlayer... Forward");
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateSeekingBackward){
        NSLog(@"moviePlayer... Backward");
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];
    [self.hashtagTextField resignFirstResponder];
}

#pragma mark - FTPhotoPostDetailsFooterViewDelegate

-(void)facebookShareButton:(id)sender{
    // Share to facebook
}

-(void)twitterShareButton:(id)sender{
    // Share to twitter
}

-(void)sendPost:(id)sender{
    [self doneButtonAction:sender];
}

#pragma mark - ()

- (NSArray *) checkForHashtag {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)"
                                                                           options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self.commentTextField.text
                                      options:0
                                        range:NSMakeRange(0,self.commentTextField.text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextField.text substringWithRange:wordRange];
        //NSLog(@"Found tag %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (NSMutableArray *) checkForMention {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)"
                                                                           options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self.commentTextField.text
                                      options:0
                                        range:NSMakeRange(0,self.commentTextField.text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextField.text substringWithRange:wordRange];
        //NSLog(@"Found mention %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (void)hideCameraView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldUploadVideo:(NSData *)aVideo {
    NSLog(@"FTEditVideoViewController::shouldUploadVideo:");
    if(!aVideo){
        return NO;
    }
    
    if ([PFUser currentUser]) {
        // Set the video
        
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        self.videoFile = [PFFile fileWithName:@"video.mov" data:aVideo];
        
        // Request a background execution task to allow us to finish uploading the video even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        
        [self.videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                // Get the first frame of the video and save it as an image
                NSURL *url = [NSURL URLWithString:self.videoFile.url];
                
                // Set video url
                [moviePlayer setContentURL:url];
                [moviePlayer prepareToPlay];
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generateImg.appliesPreferredTrackTransform = YES;
                
                NSError *error = NULL;
                CMTime time = CMTimeMake(1, 65);
                CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
                UIImage *anImage = [[UIImage alloc] initWithCGImage:refImg];
                UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(320.0f, 320.0f) interpolationQuality:kCGInterpolationHigh];
                NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
                
                // Set placeholder image
                [videoPlaceHolderView setImage:[UIImage imageWithData:imageData]];
                
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                self.imageFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
                
                [self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    [postDetailsFooterView.submitButton setEnabled:YES];
                    
                    if(!succeeded){
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }
                    
                    if(error){
                        NSLog(@"self.videoFile saveInBackgroundWithBlock: %@", error);
                    }
                }];
            }
            
            if (error) {
                NSLog(@"self.imageFile saveInBackgroundWithBlock: %@", error);
            }
        }];
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height * 3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,scrollViewHeight);
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender {
    //NSLog(@"FTEditVideoViewController::doneButtonAction:%@",sender);
    // Make sure there were no errors creating the image files
    if (!self.videoFile || !self.imageFile){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your video" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    if ([PFUser currentUser]) {        
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kFTEditVideoViewControllerUserInfoCommentKey,nil];
        }
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[self checkForHashtag]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[self checkForMention]];
        
        // create a video object
        PFObject *video = [PFObject objectWithClassName:kFTPostClassKey];
        [video setObject:[PFUser currentUser] forKey:kFTPostUserKey];
        [video setObject:self.imageFile forKey:kFTPostTypeImage];
        [video setObject:self.videoFile forKey:kFTPostTypeVideo];
        [video setObject:kFTPostTypeVideo forKey:kFTPostTypeKey];
        
        if (self.geoPoint) {
            [video setObject:self.geoPoint forKey:kFTPostLocationKey];
        }
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *videoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [videoACL setPublicReadAccess:YES];
        video.ACL = videoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.videoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.videoPostBackgroundTaskId];
        }];
        
        //NSLog(@"Save the video PFObject");
        // Save the video PFObject
        [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[FTCache sharedCache] setAttributesForPost:video likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                
                // userInfo might contain any caption which might have been posted by the uploader
                if (userInfo) {
                    NSString *commentText = [userInfo objectForKey:kFTEditVideoViewControllerUserInfoCommentKey];
                    
                    if (commentText && commentText.length != 0) {
                        // create and save photo caption
                        PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
                        [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
                        [comment setObject:video forKey:kFTActivityPostKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                        [comment setObject:hashtags forKey:kFTActivityHashtagKey];
                        [comment setObject:mentions forKey:kFTActivityMentionKey];
                        [comment setObject:commentText forKey:kFTActivityContentKey];
                        
                        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [ACL setPublicReadAccess:YES];
                        comment.ACL = ACL;
                        
                        [comment saveEventually];
                        [[FTCache sharedCache] incrementCommentCountForPost:video];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification object:video];
            } else {
                //NSLog(@"Error: %@",error);
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your video"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
            }
        }];
        
        // Dismiss this screen        
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        //NSString *caption = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //[self setCoverPhoto:self.video Caption:caption];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
    if (locationManager != nil) {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    //NSLog(@"didFailWithError: %@", error);
    
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    */
    postDetailsFooterView.locationTextField.text = @"Please visit privacy settings to enable location tracking.";
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        CLLocation *location = [locations lastObject];
        //NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
        
        self.geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                               longitude:location.coordinate.longitude];
        
        // Set location
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *placemark in placemarks) {
                self.postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                if (postDetailsFooterView) {
                    postDetailsFooterView.locationTextField.text = self.postLocation;
                }
            }
        }];
    }
}

@end

