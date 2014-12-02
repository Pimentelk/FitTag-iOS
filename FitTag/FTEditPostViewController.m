//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPostViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTEditPostViewController () {
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSData *video;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *multi;

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier postBackgroundTaskId;

@property (nonatomic, strong) UIImageView *postImageView;

@property (nonatomic, strong) FTPostDetailsFooterView *postDetailsFooterView;

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *hashtagTextField;

@property (nonatomic, assign) NSInteger scrollViewHeight;

@property (nonatomic, strong) PFGeoPoint *geoPoint;

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) PFFile *videoFile;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbFile;

@property (nonatomic, strong) NSMutableArray *photoFiles;
@property (nonatomic, strong) NSMutableArray *thumbFiles;

@property (nonatomic, strong) UIImageView *videoPlaceHolderView;

@property (nonatomic, strong) NSString *postLocation;

@property (nonatomic,readonly) UIButton *playButton;

@property (nonatomic, strong) UIImageView *videoImageView;

@property (nonatomic, strong) NSString *postType;

@end

@implementation FTEditPostViewController
@synthesize scrollView;
@synthesize fileUploadBackgroundTaskId;
@synthesize postBackgroundTaskId;
@synthesize postImageView;
@synthesize postDetailsFooterView;
@synthesize commentTextField;
@synthesize hashtagTextField;
@synthesize scrollViewHeight;
@synthesize videoPlaceHolderView;
@synthesize moviePlayer;
@synthesize playButton;
@synthesize videoImageView;
@synthesize postType;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithArray:(NSArray *)aArray {
    //NSLog(@"- (id)initWithArray:(NSArray *)aArray");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aArray) {
            return nil;
        }
        
        self.multi = aArray;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postType = @"MULTI";
        self.photoFiles = [[NSMutableArray alloc] init];
        self.thumbFiles = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithVideo:(NSData *)aVideo {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aVideo) {
            return nil;
        }
        
        self.video = aVideo;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postType = @"VIDEO";
    }
    return self;
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postBackgroundTaskId = UIBackgroundTaskInvalid;
        self.postType = @"IMAGE";
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    
    if ([self.postType isEqualToString:@"IMAGE"]) {
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
        [photoImageView setBackgroundColor:[UIColor blackColor]];
        [photoImageView setImage:self.image];
        [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.scrollView addSubview:postImageView];
        scrollViewHeight = postImageView.frame.origin.y + postImageView.frame.size.height;
        
        footerRect.origin.y = scrollViewHeight;
    }
    
    if ([self.postType isEqualToString:@"VIDEO"]) {
        videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.width)];
        [videoImageView setBackgroundColor:[UIColor blackColor]];
        [videoImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.scrollView addSubview:videoImageView];
        scrollViewHeight = videoImageView.frame.origin.y + videoImageView.frame.size.height;
        
        footerRect.origin.y = scrollViewHeight;
    }
    
    if ([self.postType isEqualToString:@"MULTI"]) {
        //NSLog(@"loadView - postType multi");
        UIScrollView *carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, self.view.frame.size.width)];
        [carousel setBackgroundColor:[UIColor blackColor]];
        
        //add the scrollview to the view
        carousel.pagingEnabled = YES;
        [carousel setAlwaysBounceVertical:NO];
        
        //setup internal views
        NSInteger numberOfViews = self.multi.count;
        
        //NSLog(@"numberOfViews: %ld",(long)numberOfViews);
        
        int i = 0;
        for (UIImage *image in self.multi) {
            CGFloat xOrigin = i * self.view.frame.size.width;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width,
                                                                                   self.view.frame.size.width)];
            [imageView setBackgroundColor:[UIColor blackColor]];
            [imageView setImage:image];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [carousel addSubview:imageView];
            i++;
        }
        //set the scroll view content size
        carousel.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.width);
        
        [self.scrollView addSubview:carousel];
        scrollViewHeight = carousel.frame.origin.y + carousel.frame.size.height;
        
        footerRect.origin.y = scrollViewHeight;
    }
    
    NSLog(@"footerRect.origin.y:%f",footerRect.origin.y);
    
    
    self.postDetailsFooterView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = postDetailsFooterView.commentField;
    self.hashtagTextField = postDetailsFooterView.hashtagTextField;
    self.commentTextField.delegate = self;
    self.hashtagTextField.delegate = self;
    self.postDetailsFooterView.delegate = self;
    
    scrollViewHeight += postDetailsFooterView.frame.size.height;
    NSLog(@"scrollViewHeight:%ld",(long)scrollViewHeight);
    
    [self.scrollView addSubview:postDetailsFooterView];
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
    [self.navigationItem setTitle: @"TAG YOUR FIT"];
    [self.navigationItem setHidesBackButton:NO];
    
    // Override the back idnicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(leftBarButtonItemHandler:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if ([self.postType isEqualToString:@"IMAGE"]) {
        [self shouldUploadImage:self.image];
    } else if ([self.postType isEqualToString:@"VIDEO"]) {
        
        // Videoplayer background image
        videoPlaceHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [videoPlaceHolderView setBackgroundColor:[UIColor clearColor]];
        [videoPlaceHolderView setContentMode:UIViewContentModeScaleAspectFill];
        
        [videoImageView addSubview:videoPlaceHolderView];
        
        // setup the video player
        moviePlayer = [[MPMoviePlayerController alloc] init];
        [moviePlayer setControlStyle:MPMovieControlStyleNone];
        [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
        [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
        [moviePlayer setShouldAutoplay:NO];
        [moviePlayer.view setFrame:CGRectMake(0, 0, 320, 320)];
        [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
        [moviePlayer.view setUserInteractionEnabled:NO];
        [moviePlayer.view setHidden:YES];
        
        [videoImageView addSubview:moviePlayer.view];
        [videoImageView bringSubviewToFront:moviePlayer.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallBack:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerStateChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadStateDidChange:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:moviePlayer];
        
        // setup the playbutton
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setFrame:CGRectMake(VIDEOCGRECTFRAMECENTER(videoImageView.frame.size.width,73),
                                             VIDEOCGRECTFRAMECENTER(videoImageView.frame.size.height,72),73,72)];
        
        [self.playButton setBackgroundImage:IMAGE_PLAY_BUTTON forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setSelected:NO];
        [self.scrollView addSubview:self.playButton];
        [self.scrollView bringSubviewToFront:self.playButton];
        [self shouldUploadVideo:self.video];
    } else if([self.postType isEqualToString:@"MULTI"]) {
        //NSLog(@"[self shouldUploadMulti:self.multi];");
        [self shouldUploadMulti:self.multi];
    } else {
        NSLog(@"No post set");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_EDIT_POST];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - checkForHashTag & Mention

- (NSArray *)checkForHashtag {
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

- (NSMutableArray *)checkForMention {
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

#pragma mark - Done Action Handlers

- (void)incrementUserPostCount {
    NSLog(@"Increment user post count");
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

- (void)postMultipleWithPhotoFiles:(NSArray *)photos
                        ThumbFiles:(NSArray *)thumbs
                          Mentions:(NSArray *)mentions
                          Hashtags:(NSArray *)hashtags
                       AndUserInfo:(NSDictionary *)userInfo {
            NSLog(@"postMultipleWithPhotoFiles;");

    NSMutableArray *posts = [[NSMutableArray alloc] init];
    for (int i = 0; i < photos.count; i++) {
        // create a post object
        //NSLog(@"create a post object");
        PFObject *post = [PFObject objectWithClassName:kFTPostClassKey];
        [post setObject:[PFUser currentUser] forKey:kFTPostUserKey];
        [post setObject:photos[i] forKey:kFTPostImageKey];
        [post setObject:thumbs[i] forKey:kFTPostThumbnailKey];
        [post setObject:kFTPostTypeGalleryImage forKey:kFTPostTypeKey];
        
        //NSLog(@"photos are public, but may only be modified by the user who uploaded them");
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        post.ACL = photoACL;
    
        [posts addObject:post];
    }
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.postBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.postBackgroundTaskId];
    }];
            
    [PFObject saveAllInBackground:posts block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //PFObject *gallery = [PFObject objectWithClassName:@"Gallery"];
            PFObject *gallery = [PFObject objectWithClassName:kFTPostClassKey];
            [gallery setObject:[PFUser currentUser] forKey:kFTPostUserKey];
            [gallery setObject:kFTPostTypeGallery forKey:kFTPostTypeKey];
            [gallery setObject:photos[0] forKey:kFTPostImageKey];
            [gallery setObject:hashtags forKey:kFTPostHashTagKey];
            [gallery setObject:posts forKey:@"posts"];
            
            if (self.geoPoint) {
                [gallery setObject:self.geoPoint forKey:kFTPostLocationKey];
            }
            
            // Save the gallery
            [gallery saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [[FTCache sharedCache] setAttributesForPost:gallery
                                                         likers:[NSArray array]
                                                     commenters:[NSArray array]
                                             likedByCurrentUser:NO
                                                    displayName:[[PFUser currentUser] objectForKey:kFTUserDisplayNameKey]];
                    
                    [self incrementUserPostCount];
                    //NSLog(@"userInfo might contain any caption which might have been posted by the uploader");
                    
                    NSString *description = EMPTY_STRING;
                    
                    // userInfo might contain any caption which might have been posted by the uploader
                    if (userInfo) {
                        NSString *commentText = [userInfo objectForKey:kFTEditPhotoViewControllerUserInfoCommentKey];
                        
                        if (commentText && commentText.length > 0) {
                            //NSLog(@"create and save photo caption");
                            // create and save photo caption
                            PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
                            [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
                            [comment setObject:gallery forKey:kFTActivityPostKey];
                            [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                            [comment setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                            [comment setObject:hashtags forKey:kFTActivityHashtagKey];
                            [comment setObject:mentions forKey:kFTActivityMentionKey];
                            [comment setObject:commentText forKey:kFTActivityContentKey];
                            
                            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                            [ACL setPublicReadAccess:YES];
                            comment.ACL = ACL;
                            
                            [comment saveEventually];
                            [[FTCache sharedCache] incrementCommentCountForPost:gallery];
                            
                            description = commentText;
                        }
                        
                    } else {
                        NSLog(@"error:%@",error);
                        //[post saveEventually];
                    }
                    
                    NSLog(@"gallery:%@",gallery.objectId);
                    NSString *link = [NSString stringWithFormat:@"http://fittag.com/viewer.php?pid=%@",gallery.objectId];
                    
                    PFFile *caption = nil;
                    if ([gallery objectForKey:kFTPostImageKey]) {
                        caption = [gallery objectForKey:kFTPostImageKey];
                    }
                    
                    // If facebook icon selected, post to facebook
                    if ([postDetailsFooterView.facebookButton isSelected]) {
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
                    if ([postDetailsFooterView.twitterButton isSelected]) {
                        NSString *status = [NSString stringWithFormat:@"Captured a healthy moment via #FitTag http://fittag.com/viewer.php?pid=%@",gallery.objectId];
                        [FTUtility shareCapturedMomentOnTwitter:status];
                    }                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification
                                                                        object:posts];
                }
            }];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Dismiss", nil] show];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.postBackgroundTaskId];
    }];
    
    // Dismiss this screen
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UIBarButtonItem LeftBarButtonItem

-(void)leftBarButtonItemHandler:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ShouldUpload

- (BOOL)shouldUploadMulti:(NSArray *)anArray {
    //NSLog(@"shouldUploadMulti:(NSArray *)anArray");
    if ([PFUser currentUser]) {

        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        
        //NSLog(@"Request a background execution task to allow us to finish uploading the photo/'s even if the app is backgrounded");
        // Request a background execution task to allow us to finish uploading the photo/'s even if the app is backgrounded
        for(UIImage *image in anArray){
            UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
            UIImage *thumbnailImage = [image thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
            //NSLog(@"JPEG to decrease file size and enable faster uploads & downloads");
            // JPEG to decrease file size and enable faster uploads & downloads
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
            NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
        
            if (!imageData || !thumbnailImageData) {
                return NO;
            }
        
            self.photoFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
            self.thumbFile = [PFFile fileWithName:@"thumbnail.png" data:imageData];

            [self.photoFiles addObject:self.photoFile];
            [self.thumbFiles addObject:self.thumbFile];
        }
        
        [PFObject saveAllInBackground:self.photoFiles block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [PFObject saveAllInBackground:self.thumbFiles block:^(BOOL succeeded, NSError *error) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    
                    if (error) {
                        NSLog(@"self.thumbnailFile saveInBackgroundWithBlock: %@", error);
                    }
                }];
            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }
            if (error) {
                NSLog(@"self.photoFiles saveInBackgroundWithBlock: %@", error);
            }
        }];
    }
    return YES;
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
    self.thumbFile = [PFFile fileWithName:@"thumbnail.png" data:imageData];
    
    if ([PFUser currentUser]) {
        // Request a background execution task to allow us to finish uploading the photo/'s even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        
        [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.thumbFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

- (BOOL)shouldUploadVideo:(NSData *)aVideo {
    
    if(!aVideo){
        return NO;
    }
    
    if ([PFUser currentUser]) {
        // Set the video
        
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        self.videoFile = [PFFile fileWithName:@"video.mp4" data:aVideo];
        
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

#pragma mark - NSKeyboardWillShow

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

#pragma mark - Video Play Button

- (void)didTapVideoPlayButtonAction:(UIButton *)sender {
    [moviePlayer play];
}

#pragma mark - NSNotification

- (void)movieFinishedCallBack:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

- (void)loadStateDidChange:(NSNotification *)notification {
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

- (void)moviePlayerStateChange:(NSNotification *)notification {
    
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
    
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updating"
                                                         message:@"Please visit privacy settings to enable location tracking."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    
    postDetailsFooterView.locationTextField.text = @"Please visit privacy settings to enable location tracking.";
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        CLLocation *location = [locations lastObject];
        NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
        
        self.geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                               longitude:location.coordinate.longitude];
        
        // Set location
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
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

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
    didTapFacebookShareButton:(UIButton *)button {
    
}

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
     didTapTwitterShareButton:(UIButton *)button
               showTweetSheet:(SLComposeViewController *)tweetSheet {
    
}

- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView
       didTapSubmitPostButton:(UIButton *)button {
    //NSLog(@"- (void)doneButtonAction:(id)sender");
    if ([PFUser currentUser]) {
        
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment, kFTEditVideoViewControllerUserInfoCommentKey, nil];
        }
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[self checkForHashtag]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[self checkForMention]];
        
        if ([self.postType isEqualToString:@"MULTI"]) {
            
            //NSLog(@"if ([self.postType isEqualToString:@MULTI])");
            if (!self.photoFiles || !self.thumbFiles) {
                //NSLog(@"(!self.photoFiles || !self.thumbFiles)");
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
                return;
            }
            
            [self postMultipleWithPhotoFiles:self.photoFiles
                                  ThumbFiles:self.thumbFiles
                                    Mentions:mentions
                                    Hashtags:hashtags
                                 AndUserInfo:userInfo];
            
        } else if ([self.postType isEqualToString:@"IMAGE"] || [self.postType isEqualToString:@"VIDEO"]) {
            
            // Make sure there were no errors creating the image files
            if (!self.photoFile || !self.thumbFile) {
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
                return;
            }
            
            // Make sure there were no errors creating the image files
            if (!self.videoFile || !self.imageFile){
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your video"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
                return;
            }
            
            // create a post object
            PFObject *post = [PFObject objectWithClassName:kFTPostClassKey];
            [post setObject:[PFUser currentUser] forKey:kFTPostUserKey];
            [post setObject:hashtags forKey:kFTPostHashTagKey];
            
            if ([self.postType isEqualToString:@"VIDEO"]) {
                [post setObject:self.imageFile forKey:kFTPostImageKey];
                [post setObject:self.videoFile forKey:kFTPostVideoKey];
                [post setObject:kFTPostVideoKey forKey:kFTPostTypeKey];
            }
            
            if ([self.postType isEqualToString:@"IMAGE"]) {
                [post setObject:self.photoFile forKey:kFTPostImageKey];
                [post setObject:self.thumbFile forKey:kFTPostThumbnailKey];
                [post setObject:kFTPostImageKey forKey:kFTPostTypeKey];
            }
            
            if (self.geoPoint) {
                [post setObject:self.geoPoint forKey:kFTPostLocationKey];
            }
            
            // photos are public, but may only be modified by the user who uploaded them
            PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [photoACL setPublicReadAccess:YES];
            post.ACL = photoACL;
            
            // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
            self.postBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.postBackgroundTaskId];
            }];
            
            // Save the Post PFObject
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [[FTCache sharedCache] setAttributesForPost:post
                                                         likers:[NSArray array]
                                                     commenters:[NSArray array]
                                             likedByCurrentUser:NO
                                                    displayName:[[PFUser currentUser] objectForKey:kFTUserDisplayNameKey]];
                    [self incrementUserPostCount];
                    
                    // userInfo might contain any caption which might have been posted by the uploader
                    if (userInfo) {
                        NSString *commentText = [userInfo objectForKey:kFTEditPhotoViewControllerUserInfoCommentKey];
                        
                        if (commentText && commentText.length != 0) {
                            // create and save photo caption
                            PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
                            [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
                            [comment setObject:post forKey:kFTActivityPostKey];
                            [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                            [comment setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                            [comment setObject:hashtags forKey:kFTActivityHashtagKey];
                            [comment setObject:mentions forKey:kFTActivityMentionKey];
                            [comment setObject:commentText forKey:kFTActivityContentKey];
                            
                            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                            [ACL setPublicReadAccess:YES];
                            comment.ACL = ACL;
                            
                            [comment saveEventually];
                            [[FTCache sharedCache] incrementCommentCountForPost:post];
                        }
                    } else {
                        [post saveEventually];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification
                                                                        object:post];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Dismiss", nil] show];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.postBackgroundTaskId];
            }];
            
            // Dismiss this screen
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            //NSString *caption = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //[self setCoverPhoto:self.image Caption:caption];
            //[self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

@end

