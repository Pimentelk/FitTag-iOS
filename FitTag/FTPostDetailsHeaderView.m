//
//  FTPhotoDetailsHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsHeaderView.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTGallerySwiperView.h"

#define PROFILE_HEXAGON_X 4
#define PROFILE_HEXAGON_Y 4
#define PROFILE_HEXAGON_WIDTH 42
#define PROFILE_HEXAGON_HEIGHT 42

#define EXTRA_PADDING 3
#define REMOVE_EXTRA_PADDING 4

#define baseHorizontalOffset 0.0f
#define baseWidth 320.0f

#define horiBorderSpacing 6.0f
#define horiMediumSpacing 8.0f

#define vertBorderSpacing 6.0f
#define vertSmallSpacing 2.0f

#define nameHeaderX baseHorizontalOffset
#define nameHeaderY 0.0f
#define nameHeaderWidth baseWidth
#define nameHeaderHeight 0.0f

#define avatarImageX horiBorderSpacing
#define avatarImageY vertBorderSpacing
#define avatarImageDim 35.0f

#define nameLabelX avatarImageX+avatarImageDim+horiMediumSpacing
#define nameLabelY avatarImageY+vertSmallSpacing
#define nameLabelMaxWidth 320.0f - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

#define timeLabelX nameLabelX
#define timeLabelMaxWidth nameLabelMaxWidth

#define mainImageX baseHorizontalOffset
#define mainImageY nameHeaderHeight
#define mainImageWidth baseWidth
#define mainImageHeight 320.0f

#define likeBarX baseHorizontalOffset
#define likeBarY nameHeaderHeight + mainImageHeight
#define likeBarWidth baseWidth
#define likeBarHeight 0.0f

#define likeButtonX 9.0f
#define likeButtonY 7.0f
#define likeButtonDim 28.0f

#define likeProfileXBase 46.0f
#define likeProfileXSpace 3.0f
#define likeProfileY 6.0f
#define likeProfileDim 30.0f

#define viewTotalHeight likeBarY+likeBarHeight
#define numLikePics 7.0f

@interface FTPostDetailsHeaderView ()

// View components
@property (nonatomic, strong) UIView *nameHeaderView;
@property (nonatomic, strong) PFImageView *postImageView;
@property (nonatomic, strong) UIView *likeBarView;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) FTGallerySwiperView *swiperView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;

// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *photographer;

// Private methods
- (void)createView;

@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation FTPostDetailsHeaderView
@synthesize post;
@synthesize moviePlayer;
@synthesize playButton;
@synthesize photographer;
@synthesize likeUsers;
@synthesize nameHeaderView;
@synthesize postImageView;
@synthesize likeBarView;
@synthesize likeButton;
@synthesize delegate;
@synthesize currentLikeAvatars;
@synthesize usernameRibbon;
@synthesize likeCounter;
@synthesize commentCounter;
@synthesize commentButton;
@synthesize moreButton;
@synthesize carousel;
@synthesize swiperView;
@synthesize avatarImageView;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost type:(NSString *)aType {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.post = aPost;
        self.type = aType;
        self.photographer = [self.post objectForKey:kFTPostUserKey];
        self.likeUsers = nil;
        
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost type:(NSString *)aType photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.post = aPost;
        self.type = aType;
        self.photographer = aPhotographer;
        self.likeUsers = theLikeUsers;
        
        self.backgroundColor = [UIColor clearColor];
        
        if (self.post && self.type && self.photographer && self.likeUsers) {
            [self createView];
        }
        
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [FTUtility drawSideDropShadowForRect:self.nameHeaderView.frame inContext:UIGraphicsGetCurrentContext()];
    [FTUtility drawSideDropShadowForRect:self.postImageView.frame inContext:UIGraphicsGetCurrentContext()];
    [FTUtility drawSideDropShadowForRect:self.likeBarView.frame inContext:UIGraphicsGetCurrentContext()];
}

#pragma mark - FTPhotoDetailsHeaderView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

- (void)setPost:(PFObject *)aPost {
    post = aPost;
    
    if (self.post && self.photographer && self.likeUsers && self.type) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (UIImageView *)getProfileHexagon {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake( 4.0f, 4.0f, 42.0f, 42.0f);
    imageView.backgroundColor = [UIColor redColor];
    
    CGRect rect = CGRectMake( 4.0f, 4.0f, 40.0f, 40.0f);
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = imageView.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
    CGFloat lcolumn = rect.size.width - sideWidth;
    CGFloat height = rect.size.height;
    CGFloat ty = (rect.size.height - height) / 2;
    CGFloat tmy = rect.size.height / 4;
    CGFloat bmy = rect.size.height - tmy;
    CGFloat by = rect.size.height;
    CGFloat rightmost = rect.size.width;
    
    [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
    
    [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
    
    hexagonMask.path = hexagonPath.CGPath;
    
    imageView.layer.mask = hexagonMask;
    [imageView.layer addSublayer:hexagonBorder];
    
    return imageView;
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
    likeUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:kFTUserDisplayNameKey];
        NSString *displayName2 = [liker2 objectForKey:kFTUserDisplayNameKey];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (FTProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }
    
    [likeCounter setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.likeUsers.count] forState:UIControlStateNormal];
    
    self.currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:likeUsers.count];
    NSInteger i;
    NSInteger numOfPics = numLikePics > self.likeUsers.count ? self.likeUsers.count : numLikePics;
    
    for (i = 0; i < numOfPics; i++) {
        FTProfileImageView *profilePic = [[FTProfileImageView alloc] init];
        [profilePic setFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setFile:[[self.likeUsers objectAtIndex:i] objectForKey:kFTUserProfilePicSmallKey]];
        [likeBarView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( -1.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    }
    [likeButton setSelected:selected];
}

- (void)reloadLikeBar {
    self.likeUsers = [[FTCache sharedCache] likersForPost:self.post];
    [self setLikeButtonState:[[FTCache sharedCache] isPostLikedByCurrentUser:self.post]];
    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - NSNotificationCenter

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
        [self.postImageView setHidden:YES];
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
            [self.postImageView setHidden:YES];
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
        [self.postImageView setHidden:NO];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > (scrollView.contentSize.width - 320))
        [self killScroll];
    
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        if (previousPage < page) {
            [self.swiperView onGallerySwipedLeft: page];
        } else if (previousPage > page) {
            [self.swiperView onGallerySwipedRight: page];
        }
        previousPage = page;
    }
}

#pragma mark - ()

- (void)createView {
    
    self.clipsToBounds = YES;
    self.nameHeaderView.clipsToBounds = YES;
    self.superview.clipsToBounds = YES;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    // Create middle section of the header view; the image
    
    self.postImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
    self.postImageView.backgroundColor = [UIColor blackColor];
    self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    PFFile *imageFile = [self.post objectForKey:kFTPostImageKey];
    
    if (imageFile) {
        self.postImageView.file = imageFile;
        [self.postImageView loadInBackground];
    }
    
    [self addSubview:self.postImageView];
    
    // set config depending on post type
    
    if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeGallery]) {
        [self configGallery:self.post];
    } else if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeVideo]) {
        [self configVideo:self.post];
    } else if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeImage]) {
        [self configImage:self.post];
    } else {
        NSLog(@"No post type...");
        return;
    }
    
    // Load data for header
    
    [self configHeader:self.photographer];
    
    // Get loction
    
    [self configLocation:[self.post objectForKey:kFTPostLocationKey]];
    
    // Create bottom section for the header view; the likes
    
    UIView *previewButtons = [[UIView alloc] init];
    previewButtons.frame = CGRectMake( 120.0f, 295.0f, 200.0f, 22.0f);
    previewButtons.backgroundColor = [UIColor clearColor];
    [self addSubview:previewButtons];
    
    // Create the heart-shaped like button

    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton setFrame:CGRectMake( 5.0f, 1.0f, 21.0f, 18.0f )];
    [likeButton setBackgroundColor:[UIColor clearColor]];
    [likeButton setAdjustsImageWhenDisabled:NO];
    [likeButton setAdjustsImageWhenHighlighted:NO];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART_SELECTED] forState:UIControlStateSelected];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART_SELECTED] forState:UIControlStateHighlighted];
    [previewButtons addSubview:likeButton];
    
    likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x + 3.0f, likeButton.frame.origin.y, 37.0f, 19.0f)];
    [likeCounter setBackgroundColor:[UIColor clearColor]];
    [likeCounter setTitle:COUNTER_ZERO forState:UIControlStateNormal];
    [likeCounter setBackgroundImage:[UIImage imageNamed:ACTION_LIKE_COMMENT_BOX] forState:UIControlStateNormal];
    [previewButtons addSubview:likeCounter];
    
    commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setFrame:CGRectMake(likeCounter.frame.size.width + likeCounter.frame.origin.x + 15.0f, likeCounter.frame.origin.y, 21.0f, 18.0f)];
    [commentButton setBackgroundColor:[UIColor clearColor]];
    [commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [commentButton setBackgroundImage:[UIImage imageNamed:ACTION_COMMENT_BUBBLE] forState:UIControlStateNormal];
    [commentButton setSelected:NO];
    [previewButtons addSubview:commentButton];
    
    commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentCounter setFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 3.0f, self.commentButton.frame.origin.y, 37.0f, 19.0f)];
    [commentCounter setBackgroundColor:[UIColor clearColor]];
    [commentCounter setBackgroundImage:[UIImage imageNamed:ACTION_LIKE_COMMENT_BOX] forState:UIControlStateNormal];
    [commentCounter setTitle:COUNTER_ZERO forState:UIControlStateNormal];
    [previewButtons addSubview:commentCounter];
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(commentCounter.frame.size.width + commentCounter.frame.origin.x + 15.0f, commentCounter.frame.origin.y, 35.0f, 19.0f)];
    [moreButton setBackgroundColor:[UIColor clearColor]];
    [moreButton setBackgroundImage:[UIImage imageNamed:ACTION_MORE] forState:UIControlStateNormal];
    [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [previewButtons addSubview:moreButton];
    
    [self bringSubviewToFront:previewButtons];
    [self reloadLikeBar];
}

#pragma mark - config

- (void)configHeader:(PFObject *)aPhotographer {
    [aPhotographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            // Create top of header view with name and avatar
            
            UIImageView *profileHexagon = [FTUtility getProfileHexagonWithX:PROFILE_HEXAGON_X
                                                                          Y:PROFILE_HEXAGON_Y
                                                                      width:PROFILE_HEXAGON_WIDTH
                                                                     hegiht:PROFILE_HEXAGON_HEIGHT];
            
            avatarImageView = [[FTProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
            [avatarImageView setFile:[self.photographer objectForKey:kFTUserProfilePicSmallKey]];
            [avatarImageView setBackgroundColor:[UIColor blackColor]];
            [avatarImageView setFrame:profileHexagon.frame];
            [avatarImageView setUserInteractionEnabled:YES];
            [avatarImageView.layer setMask:profileHexagon.layer.mask];
            [avatarImageView.profileButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // Ribbon
            
            usernameRibbon = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *image = [FTPostDetailsHeaderView imageWithImage:[UIImage imageNamed:IMAGE_USERNAME_RIBBON] scaledToSize:CGSizeMake(88.0f,20.0f)];
            [usernameRibbon setBackgroundColor:[UIColor colorWithPatternImage:image]];
            [usernameRibbon setFrame:CGRectMake(avatarImageView.frame.size.width + avatarImageView.frame.origin.x - 4,
                                                avatarImageView.frame.origin.y + 10, 88.0f, 20.0f)];
            [usernameRibbon setUserInteractionEnabled:YES];
            [usernameRibbon addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [usernameRibbon setTitle:[self.photographer objectForKey:kFTUserDisplayNameKey] forState:UIControlStateNormal];
            [usernameRibbon.titleLabel setFont:BENDERSOLID(11)];
            [usernameRibbon setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
            [usernameRibbon setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];

            [self addSubview:usernameRibbon];
            [self addSubview:avatarImageView];
            
            [self setNeedsDisplay];
        }
    }];
}

- (void)configGallery:(PFObject *)aGallery {
    NSLog(@"%@::configGallery",VIEWCONTROLLER_POST_HEADER);
    [PFObject fetchAllIfNeededInBackground:[aGallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320.0f,320.0f)];
            [carousel setUserInteractionEnabled:YES];
            [carousel setDelaysContentTouches:YES];
            [carousel setExclusiveTouch:YES];
            [carousel setCanCancelContentTouches:YES];
            [carousel setBackgroundColor:[UIColor blackColor]];
            [carousel setDelegate:self];
            //add the scrollview to the view
            carousel.pagingEnabled = YES;
            [carousel setAlwaysBounceVertical:NO];
            [carousel setContentSize: CGSizeMake(320.0f * objects.count, 320.0f)];
            
            swiperView = [[FTGallerySwiperView alloc] initWithFrame:CGRectMake(usernameRibbon.frame.origin.x + EXTRA_PADDING,
                                                                               usernameRibbon.frame.origin.y + usernameRibbon.frame.size.height,
                                                                               usernameRibbon.frame.size.width - REMOVE_EXTRA_PADDING,
                                                                               usernameRibbon.frame.size.height)];
            
            int i = 0;
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:kFTPostImageKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                        //singleTap.numberOfTapsRequired = 1;
                        
                        CGFloat xOrigin = i * 320;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 320.0f, 320.0f)];
                        [imageView setBackgroundColor:[UIColor blackColor]];
                        UIImage *image = [UIImage imageWithData:data];
                        [imageView setImage:image];
                        [imageView setClipsToBounds:YES];
                        [imageView setContentMode:UIViewContentModeScaleAspectFill];
                        [imageView setUserInteractionEnabled:YES];
                        //[imageView addGestureRecognizer:singleTap];
                        [carousel addSubview:imageView];
                    }
                }];
                i++;
                
                if (objects.count == i) {
                    [self addSubview:carousel];
                    [self sendSubviewToBack:carousel];
                    [self.postImageView setHidden:YES];
                }
            }
            
            [self.swiperView setNumberOfDashes:i];
            [self addSubview:self.swiperView];
        }
    }];
}

- (void)configVideo:(PFObject *)aPost {
    NSLog(@"%@::configVideo:",VIEWCONTROLLER_POST_HEADER);
    
    // setup the video player
    PFFile *videoFile = [aPost objectForKey:kFTPostVideoKey];
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer setContentURL:[NSURL URLWithString:videoFile.url]];
    [moviePlayer.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setUserInteractionEnabled:NO];
    [moviePlayer.view setHidden:YES];
    
    [self addSubview:moviePlayer.view];
    
    float centerX = (self.frame.size.width - 60) / 2;
    float centerY = (self.frame.size.height - 60) / 2;
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setFrame:CGRectMake(centerX,centerY,60.0f,60.0f)];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setSelected:NO];
    
    [self addSubview:self.playButton];
    [self bringSubviewToFront:self.playButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
}

- (void)configImage:(PFObject *)aPost {
    NSLog(@"%@::configImage:",VIEWCONTROLLER_POST_HEADER);
    
}

- (void)configLocation:(PFGeoPoint *)geoPoint {
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                for (CLPlacemark *placemark in placemarks) {
                    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, 110, 40)];
                    NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                    if (postLocation) {
                        [locationLabel setUserInteractionEnabled:YES];
                        [locationLabel setText:postLocation];
                        [locationLabel setFont:[UIFont systemFontOfSize:12.0f]];
                        [locationLabel setBackgroundColor:[UIColor clearColor]];
                        [locationLabel setTextColor:[UIColor whiteColor]];
                        
                        UITapGestureRecognizer *locationTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLocationAction:)];
                        locationTapRecognizer.numberOfTapsRequired = 1;
                        [locationLabel addGestureRecognizer:locationTapRecognizer];
                        
                    }
                    
                    [self addSubview:locationLabel];
                    [self bringSubviewToFront:locationLabel];
                }
            } else {
                NSLog(@"ERROR: %@",error);
            }
        }];
    } else {
        NSLog(@"No geopoint...");
    }
}

#pragma mark - ()

- (void)killScroll {
    self.carousel.scrollEnabled = NO;
    self.carousel.scrollEnabled = YES;
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapLikePhotoButtonAction:");
    BOOL liked = !button.selected;
    [button removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setLikeButtonState:liked];
    
    NSArray *originalLikeUsersArray = [NSArray arrayWithArray:self.likeUsers];
    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[self.likeUsers count]];
    
    for (PFUser *likeUser in self.likeUsers) {
        // add all current likeUsers BUT currentUser
        if (![[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newLikeUsersSet addObject:likeUser];
        }
    }
    
    if (liked) {
        [[FTCache sharedCache] incrementLikerCountForPost:self.post];
        [newLikeUsersSet addObject:[PFUser currentUser]];
    } else {
        [[FTCache sharedCache] decrementLikerCountForPost:self.post];
    }
    
    [[FTCache sharedCache] setPostIsLikedByCurrentUser:self.post liked:liked];
    
    [self setLikeUsers:[newLikeUsersSet allObjects]];
    
    if (liked) {
        [FTUtility likePhotoInBackground:self.post block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
            }
        }];
    } else {
        [FTUtility unlikePhotoInBackground:self.post block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification
                                                        object:self.post
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked]
                                                                                           forKey:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapLikerButtonAction:");
    PFUser *user = [self.likeUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate postDetailsHeaderView:self didTapUserButton:button user:user];
    }
}

- (void)didTapUserNameButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapUserNameButtonAction:");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate postDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    }
}

- (void)didTapUserButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapUserButtonAction:");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate postDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    }
}
/*
- (void)didTapImageInGalleryAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapImageInGalleryAction");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapImageInGalleryAction:user:)]) {
        [delegate postDetailsHeaderView:self didTapImageInGalleryAction:button user:self.photographer];
    }
}
*/
- (void)didTapVideoPlayButtonAction:(id)sender {
    NSLog(@"- (void)didTapVideoPlayButtonAction:(id)sender");
    [moviePlayer play];
}

- (void)didTapLocationAction:(UIButton *)sender {
    NSLog(@"FTPostDetailsHeaderView::didTapLocationAction");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapLocation:post:)]){
        [delegate postDetailsHeaderView:self didTapLocation:sender post:post];
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
