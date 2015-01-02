//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditVideoViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTEditVideoViewController (){
    CLLocationManager *locationManager;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSData *videoData;
@property (nonatomic, strong) UITextView *commentTextView;
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
@property (nonatomic, strong) UISwitch *shareLocationSwitch;
@property UIScrollView *originalScrollView;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) FTSuggestionTableView *suggestionTableView;
@property (nonatomic, strong) PFObject *place;
@end

@implementation FTEditVideoViewController
@synthesize scrollView;
@synthesize commentTextView;
@synthesize fileUploadBackgroundTaskId;
@synthesize videoPostBackgroundTaskId;
@synthesize hashtagTextField;
@synthesize scrollViewHeight;
@synthesize postDetailsFooterView;
@synthesize moviePlayer;
@synthesize playButton;
@synthesize videoImageView;
@synthesize videoPlaceHolderView;
@synthesize shareLocationSwitch;
@synthesize originalScrollView;
@synthesize cancelButton;
@synthesize suggestionTableView;
@synthesize place;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithVideo:(NSData *)videoData {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        //NSLog(@"aVideo: %@",aVideo);
        if (!videoData) {
            return nil;
        }
        
        self.videoData = videoData;
        self.videoFile = [PFFile fileWithName:@"video.mp4" data:self.videoData];
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.videoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [videoImageView setBackgroundColor:[UIColor clearColor]];
    [videoImageView setContentMode:CONTENTMODEVIDEO];
    
    [self.scrollView addSubview:videoImageView];
    
    // Footer view
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    footerRect.origin.y = videoImageView.frame.origin.y + videoImageView.frame.size.height;
    
    postDetailsFooterView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextView = postDetailsFooterView.commentView;
    self.hashtagTextField = postDetailsFooterView.hashtagTextField;
    self.shareLocationSwitch = postDetailsFooterView.shareLocationSwitch;
    
    self.commentTextView.delegate = self;
    self.hashtagTextField.delegate = self;
    postDetailsFooterView.delegate = self;
    [postDetailsFooterView.submitButton setEnabled:NO];
    [self.scrollView addSubview:postDetailsFooterView];
    scrollViewHeight = videoImageView.frame.origin.y + videoImageView.frame.size.height + postDetailsFooterView.frame.size.height;
    NSLog(@"scrollViewHeight:%ld",(long)scrollViewHeight);
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, scrollViewHeight)];
}

- (void)didTapVideoPlayButtonAction:(UIButton *)sender {
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
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
    [self.navigationItem setTitle:@"TAG YOUR FIT"];
    [self.navigationItem setHidesBackButton:NO];
    
    // Override the back idnicator
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // setup the video player
    //NSLog(@"FTEditVideoViewController::Setup video...");
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
    [self.moviePlayer setScalingMode:SCALINGMODE];
    [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [self.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [self.moviePlayer.view setUserInteractionEnabled:NO];
    [self.moviePlayer.view setAlpha:0];
    
    [videoImageView addSubview:self.moviePlayer.view];
    [videoImageView bringSubviewToFront:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStateChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
    
    // Write video locally
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSLog(@"paths %@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"documentsDirectory %@",documentsDirectory);
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myvideo.mp4"];
    //NSLog(@"path %@",path);
    [self.videoData writeToFile:path atomically:YES];
    NSURL *url = [NSURL fileURLWithPath:path];
    //NSLog(@"url %@",url);
    
    // Set video url and prepare to play
    [moviePlayer setContentURL:url];
    [moviePlayer prepareToPlay];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    
    NSError *error = NULL;
    CMTime time = CMTimeMake(1, 65);
    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage *anImage = [[UIImage alloc] initWithCGImage:refImg];
    UIImage *resizedImage = [anImage resizedImageWithContentMode:CONTENTMODEVIDEO
                                                          bounds:CGSizeMake(640, 640)
                                            interpolationQuality:kCGInterpolationHigh];
    
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    self.imageFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
    
    // Videoplayer background image
    videoPlaceHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [videoPlaceHolderView setBackgroundColor:[UIColor clearColor]];
    [videoPlaceHolderView setContentMode:CONTENTMODEVIDEO];
    [videoPlaceHolderView setImage:[UIImage imageWithData:imageData]];
    
    [self.scrollView addSubview:videoPlaceHolderView];
    [self.scrollView sendSubviewToBack:videoPlaceHolderView];
     
    [moviePlayer.backgroundView setBackgroundColor:[UIColor clearColor]];
    for(UIView *aSubView in moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    // setup the playbutton
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setFrame:CGRectMake(VIDEOCGRECTFRAMECENTER(videoImageView.frame.size.width,73),
                                         VIDEOCGRECTFRAMECENTER(videoImageView.frame.size.height,72),73,72)];
    [self.playButton setBackgroundImage:IMAGE_PLAY_BUTTON forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setSelected:NO];
    
    [self.scrollView addSubview:self.playButton];
    [self.scrollView bringSubviewToFront:self.playButton];
    
    [postDetailsFooterView.submitButton setEnabled:YES];
    
    // Setup the suggestions view
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    originalScrollView = self.scrollView;
    
    // Cancel button
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapcancelButtonAction:)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    
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
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_EDIT_VIDEO];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - FTPlacesViewControllerDelegate

- (void)placesViewController:(FTPlacesViewController *)placesViewController didTapSelectPlace:(PFObject *)aPlace {
    
    place = aPlace;
    
    NSLog(@"placesViewController:didTapSelectPlace:%@",place);
    
    if ([place objectForKey:kFTPlaceNameKey]) {
        NSLog(@"place selected:%@",[place objectForKey:kFTPlaceNameKey]);
        [postDetailsFooterView.shareLocationLabel setText:[place objectForKey:kFTPlaceNameKey]];
    }
}

- (void)placesViewController:(FTPlacesViewController *)placesViewController didTapCancelButton:(UIButton *)button {
    place = nil;
}


#pragma mark - FTSuggestionTableViewDelegate

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectHashtag:(NSString *)hashtag completeString:(NSString *)completeString {
    if (hashtag) {
        //NSString *hashtagString = [@"#" stringByAppendingString:hashtag];
        NSString *replaceString = [commentTextView.text stringByReplacingOccurrencesOfString:completeString withString:hashtag];
        [commentTextView setText:replaceString];
    }
}

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectUser:(PFUser *)user completeString:(NSString *)completeString {
    if ([user objectForKey:kFTUserDisplayNameKey]) {
        NSString *displayname = [user objectForKey:kFTUserDisplayNameKey];
        //NSString *mentionString = [@"@" stringByAppendingString:displayname];
        NSString *replaceString = [commentTextView.text stringByReplacingOccurrencesOfString:completeString withString:displayname];
        [commentTextView setText:replaceString];
    }
}

-(void)movieFinishedCallBack:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

-(void)loadStateDidChange:(NSNotification *)notification{
    
    NSLog(@"loadStateDidChange: %@",notification);
    
    if (self.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        NSLog(@"loadState... MPMovieLoadStatePlayable");
    }
    
    if (self.moviePlayer.loadState & MPMovieLoadStatePlaythroughOK) {
        //[moviePlayer.view setHidden:NO];
        
        NSLog(@"loadState... MPMovieLoadStatePlaythroughOK");
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
    
    NSLog(@"moviePlayerStateChange: %@",notification);
    
    if (self.moviePlayer.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK)) {
        //NSLog(@"loadState... MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK..");
        [self.playButton setHidden:YES];
        
        if (self.moviePlayer.playbackState & MPMoviePlaybackStatePlaying){
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
            [UIView animateWithDuration:1 animations:^{
                [self.moviePlayer.view setAlpha:1];
            }];
        }
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateStopped){
        [self.playButton setHidden:NO];
        
        NSLog(@"moviePlayer... MPMoviePlaybackStateStopped");
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStatePaused){
        [self.playButton setHidden:NO];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.moviePlayer.view setAlpha:0];
            [self.moviePlayer prepareToPlay];
        }];
        
        //NSLog(@"moviePlayer... MPMoviePlaybackStatePaused");
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateInterrupted){
        //NSLog(@"moviePlayer... Interrupted");
        //[self.moviePlayer stop];
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateSeekingForward){
        //NSLog(@"moviePlayer... Forward");
    }
    
    if (self.moviePlayer.playbackState & MPMoviePlaybackStateSeekingBackward){
        //NSLog(@"moviePlayer... Backward");
    }
}

#pragma mark - UITextFieldDelegate

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
    [self.navigationItem setRightBarButtonItem:cancelButton];
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
    [self.commentTextView resignFirstResponder];
    [self.hashtagTextField resignFirstResponder];
}

#pragma mark - FTPhotoPostDetailsFooterViewDelegate

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
 didChangeShareLocationSwitch:(UISwitch *)lever {
    FTPlacesViewController *placesTableViewController = [[FTPlacesViewController alloc] init];
    [placesTableViewController setGeoPoint:self.geoPoint];
    [placesTableViewController setDelegate:self];
    [self.navigationController pushViewController:placesTableViewController animated:YES];
}

-(void)facebookShareButton:(id)sender{
    // Share to facebook
    [[[UIAlertView alloc] initWithTitle:@"Disabled"
                                message:@"Hey! Facebook share controls have been disabled on this screen :("
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

-(void)twitterShareButton:(id)sender{
    // Share to twitter
    [[[UIAlertView alloc] initWithTitle:@"Disabled"
                                message:@"Hey! Twitter share controls have been disabled on this screen :("
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - ()

- (void)didTapcancelButtonAction:(id)sender {
    
    [self.scrollView setScrollEnabled:YES];
    
    [commentTextView resignFirstResponder];
    [suggestionTableView setAlpha:0];
    [self.navigationItem setRightBarButtonItem:nil];
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,scrollViewHeight);
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)incrementUserPostCount {
    // Increment user post count
    PFUser *user = [PFUser currentUser];
    [user incrementKey:kFTUserPostCountKey byAmount:[NSNumber numberWithInt:1]];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            long int postCount = (long)[[user objectForKey:kFTUserPostCountKey] integerValue];
            //NSLog(@"postCount %ld",postCount);
            
            NSNumber *rewardCount = [NSNumber numberWithUnsignedInteger:(postCount / 10)];
            //NSLog(@"rewardCount %@",rewardCount);
            
            [user setValue:rewardCount forKey:kFTUserRewardsEarnedKey];
            [user saveInBackground];
        }
    }];
}

- (NSArray *)checkForHashtag {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)"
                                                                           options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self.commentTextView.text
                                      options:0
                                        range:NSMakeRange(0,self.commentTextView.text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextView.text substringWithRange:wordRange];
        //NSLog(@"Found tag %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (NSMutableArray *) checkForMention {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)"
                                                                           options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self.commentTextView.text
                                      options:0
                                        range:NSMakeRange(0,self.commentTextView.text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextView.text substringWithRange:wordRange];
        //NSLog(@"Found mention %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (void)didTapBackButtonAction:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Video Alert"
                                message:@"Returning to the capture screen will cause your video to be deleted. Are you sure you want to continue?"
                               delegate:self
                      cancelButtonTitle:@"cancel"
                      otherButtonTitles:@"yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
        
        }
            break;
        case 1: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
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

    //NSLog(@"FTEditVideoViewController::doneButtonAction:%@",sender);
    // Make sure there were no errors creating the image files
    if (!self.videoFile || !self.imageFile){
        [[[UIAlertView alloc] initWithTitle:@"Missing Video"
                                    message:@"Something went wrong, we couldn't post your video."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    if ([PFUser currentUser]) {
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedComment.length != 0 && ![trimmedComment isEqualToString:CAPTION_TEXT]) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kFTEditPostViewControllerUserInfoCommentKey,nil];
        }
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[self checkForHashtag]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[self checkForMention]];
        
        // create a video object
        PFObject *video = [PFObject objectWithClassName:kFTPostClassKey];
        [video setObject:[PFUser currentUser] forKey:kFTPostUserKey];
        [video setObject:self.imageFile forKey:kFTPostTypeImage];
        [video setObject:self.videoFile forKey:kFTPostTypeVideo];
        [video setObject:kFTPostTypeVideo forKey:kFTPostTypeKey];
        [video setObject:hashtags forKey:kFTPostHashTagKey];
        [video setObject:mentions forKey:kFTPostMentionKey];
        
        NSString *description = EMPTY_STRING;
        
        // userInfo might contain any caption which might have been posted by the uploader
        if (userInfo) {
            NSString *commentText = [userInfo objectForKey:kFTEditPostViewControllerUserInfoCommentKey];
            
            if (commentText && commentText.length > 0) {
                // create and save photo caption
                //NSLog(@"video caption");
                [video setObject:commentText forKey:kFTPostCaptionKey];
                description = commentText;
            }
        }
        
        if ([self.shareLocationSwitch isOn]) {
            
            if (self.geoPoint) {
                [video setObject:self.geoPoint forKey:kFTPostLocationKey];
            }
            
            if (place) {
                [video setObject:place forKey:kFTPostPlaceKey];
            }
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
                [self incrementUserPostCount];
                
                NSLog(@"gallery:%@",video.objectId);
                NSString *link = [NSString stringWithFormat:@"http://fittag.com/viewer.php?pid=%@",video.objectId];
                
                PFFile *caption = nil;
                if ([video objectForKey:kFTPostImageKey]) {
                    caption = [video objectForKey:kFTPostImageKey];
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
                    NSString *status = [NSString stringWithFormat:@"Captured a healthy moment via #FitTag http://fittag.com/viewer.php?pid=%@",video.objectId];
                    [FTUtility shareCapturedMomentOnTwitter:status];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification object:video];
            } else {
                //NSLog(@"Error: %@",error);
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your video"
                                            message:@"There was a problem uploading your video. Try again or report this problem if it continues."
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
        
        // Dismiss this screen
        [FTUtility showHudMessage:@"uploading.." WithDuration:1];
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

