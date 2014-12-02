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
#define nameHeaderHeight 44.0f

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
#define likeBarHeight 30.0f

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
//@property (nonatomic, strong) FTGallerySwiperView *swiperView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *photographer;
@property (nonatomic, strong) UILabel *locationLabel;
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
//@synthesize usernameRibbon;
@synthesize likeCounter;
@synthesize commentCounter;
@synthesize commentButton;
@synthesize moreButton;
@synthesize carousel;
///@synthesize swiperView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationLabel;

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
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

- (void)setPost:(PFObject *)aPost {
    post = aPost;
    
    if (self.post && self.photographer && self.likeUsers && self.type) {
        [self createView];
        [self setNeedsDisplay];
    }
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
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 0)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 0, 0, 0)];
        [[likeButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
}

- (void)loadStateDidChange:(NSNotification *)notification {
    //NSLog(@"loadStateDidChange: %@",notification);
    switch (moviePlayer.loadState) {
        case MPMovieLoadStatePlayable: {
            NSLog(@"moviePlayer... MPMovieLoadStatePlayable");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMovieLoadStatePlaythroughOK: {
            NSLog(@"moviePlayer... MPMovieLoadStatePlaythroughOK");
            
        }
            break;
        case MPMovieLoadStateStalled: {
            NSLog(@"moviePlayer... MPMovieLoadStateStalled");
            
        }
            break;
        case MPMovieLoadStateUnknown: {
            NSLog(@"moviePlayer... MPMovieLoadStateUnknown");
            
        }
            break;
        default:
            break;
    }
}

- (void)moviePlayerStateChange:(NSNotification *)notification {
    //NSLog(@"moviePlayerStateChange: %@",notification);
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped: {
            NSLog(@"moviePlayer... MPMoviePlaybackStateStopped");
            
        }
            break;
        case MPMoviePlaybackStatePlaying: {
            NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
            NSLog(@"moviePlayer... MPMovieLoadStatePlayable");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMoviePlaybackStatePaused: {
            NSLog(@"moviePlayer... MPMoviePlaybackStatePaused");
            [UIView animateWithDuration:0.3 animations:^{
                [moviePlayer.view setAlpha:0];
                [moviePlayer prepareToPlay];
            }];
        }
            break;
        case MPMoviePlaybackStateInterrupted: {
            NSLog(@"moviePlayer... MPMoviePlaybackStateInterrupted");
            
        }
            break;
        case MPMoviePlaybackStateSeekingForward: {
            NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingForward");
            
        }
            break;
        case MPMoviePlaybackStateSeekingBackward: {
            NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingBackward");
            
        }
            break;
        default:
            break;
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
            //[self.swiperView onGallerySwipedLeft: page];
        } else if (previousPage > page) {
            //[self.swiperView onGallerySwipedRight: page];
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
    self.postImageView.clipsToBounds = YES;
    
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
    
    UIView *postButtons = [[UIView alloc] init];
    postButtons.frame = CGRectMake( 0, mainImageHeight + nameHeaderHeight, self.frame.size.width, likeBarHeight);
    postButtons.backgroundColor = FT_GRAY;
    [self addSubview:postButtons];
    
    // post buttons
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, BUTTONS_TOP_PADDING, 120, 20)];
    [postButtons addSubview:locationLabel];
    
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton setFrame:CGRectMake(locationLabel.frame.size.width + locationLabel.frame.origin.y, BUTTONS_TOP_PADDING, 21, 18)];
    [likeButton setBackgroundColor:[UIColor clearColor]];
    [likeButton setAdjustsImageWhenDisabled:NO];
    [likeButton setAdjustsImageWhenHighlighted:NO];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART_SELECTED] forState:UIControlStateSelected];
    [likeButton setBackgroundImage:[UIImage imageNamed:ACTION_HEART_SELECTED] forState:UIControlStateHighlighted];
    [postButtons addSubview:likeButton];
    
    likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x, BUTTONS_TOP_PADDING, 37, 19)];
    [likeCounter setBackgroundColor:[UIColor clearColor]];
    [likeCounter setTitle:COUNTER_ZERO forState:UIControlStateNormal];
    [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
    [likeCounter.titleLabel setFont:BENDERSOLID(16)];
    [likeCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [likeCounter setBackgroundImage:[UIImage imageNamed:ACTION_LIKE_COMMENT_BOX] forState:UIControlStateNormal];
    [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [postButtons addSubview:likeCounter];
    
    commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setFrame:CGRectMake(likeCounter.frame.size.width + likeCounter.frame.origin.x, BUTTONS_TOP_PADDING, 21, 18)];
    [commentButton setBackgroundColor:[UIColor clearColor]];
    [commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [commentButton setBackgroundImage:[UIImage imageNamed:ACTION_COMMENT_BUBBLE] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(didTapCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setSelected:NO];
    [postButtons addSubview:commentButton];
    
    commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentCounter setFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width, BUTTONS_TOP_PADDING, 37, 19)];
    [commentCounter setBackgroundColor:[UIColor clearColor]];
    [commentCounter setTitle:COUNTER_ZERO forState:UIControlStateNormal];
    [commentCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
    [commentCounter.titleLabel setFont:BENDERSOLID(16)];
    [commentCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [commentCounter setBackgroundImage:[UIImage imageNamed:ACTION_LIKE_COMMENT_BOX] forState:UIControlStateNormal];
    [commentCounter addTarget:self action:@selector(didTapCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [postButtons addSubview:commentCounter];
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(self.frame.size.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
    [moreButton setBackgroundColor:[UIColor clearColor]];
    [moreButton setBackgroundImage:[UIImage imageNamed:ACTION_MORE] forState:UIControlStateNormal];
    [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [postButtons addSubview:moreButton];
    
    [self bringSubviewToFront:postButtons];
    [self reloadLikeBar];
}

#pragma mark - config

- (void)configHeader:(PFObject *)aPhotographer {
    [aPhotographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            avatarImageView = [[FTProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
            [avatarImageView setFile:[self.photographer objectForKey:kFTUserProfilePicSmallKey]];
            [avatarImageView setBackgroundColor:[UIColor blackColor]];
            [avatarImageView setUserInteractionEnabled:YES];
            [avatarImageView setFrame:CGRectMake(AVATAR_X,AVATAR_Y,AVATAR_WIDTH,AVATAR_HEIGHT)];
            [avatarImageView.layer setCornerRadius:CORNERRADIUS(AVATAR_WIDTH)];
            [avatarImageView setClipsToBounds:YES];
            [avatarImageView.profileButton addTarget:self
                                              action:@selector(didTapUserNameButtonAction:)
                                    forControlEvents:UIControlEventTouchUpInside];
            
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.750f] forState:UIControlStateNormal];
            [self.userButton setTitle:[self.photographer objectForKey:kFTUserDisplayNameKey] forState:UIControlStateNormal];
            [self.userButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
            [self.userButton.titleLabel setFont:BENDERSOLID(18)];
            [self.userButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.userButton.titleLabel setShadowOffset:CGSizeMake(0,1)];

            // we resize the button to fit the user's name to avoid having a huge touch area
            CGFloat constrainWidth = self.frame.size.width;
            CGFloat userButtonPointWidth = AVATAR_X + AVATAR_WIDTH + 9;
            CGFloat userButtonPointHeight = (nameHeaderHeight - 10) / 2;
            CGPoint userButtonPoint = CGPointMake(userButtonPointWidth,userButtonPointHeight);
            constrainWidth -= userButtonPoint.x;
            CGSize constrainSize = CGSizeMake(constrainWidth, nameHeaderHeight - userButtonPoint.y*2.0f);
            
            CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                                  options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                               attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                                  context:nil].size;
            
            CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
            [self.userButton setFrame:userButtonFrame];
            
            [self addSubview:userButton];
            [self addSubview:avatarImageView];
            
            [self setNeedsDisplay];
        }
    }];
}

- (void)configGallery:(PFObject *)aGallery {
    NSLog(@"%@::configGallery",VIEWCONTROLLER_POST_HEADER);
    [PFObject fetchAllIfNeededInBackground:[aGallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, nameHeaderHeight, 320, 320)];
            [carousel setUserInteractionEnabled:YES];
            [carousel setDelaysContentTouches:YES];
            [carousel setExclusiveTouch:YES];
            [carousel setCanCancelContentTouches:YES];
            [carousel setBackgroundColor:[UIColor blackColor]];
            [carousel setDelegate:self];
            //add the scrollview to the view
            carousel.pagingEnabled = YES;
            [carousel setAlwaysBounceVertical:NO];
            [carousel setContentSize: CGSizeMake(320 * objects.count, 320)];
            /*
            swiperView = [[FTGallerySwiperView alloc] initWithFrame:CGRectMake(usernameRibbon.frame.origin.x + EXTRA_PADDING,
                                                                               usernameRibbon.frame.origin.y + usernameRibbon.frame.size.height,
                                                                               usernameRibbon.frame.size.width - REMOVE_EXTRA_PADDING,
                                                                               usernameRibbon.frame.size.height)];
            */
            int i = 0;
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:kFTPostImageKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                        //singleTap.numberOfTapsRequired = 1;
                        
                        CGFloat xOrigin = i * 320;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 320, 320)];
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
            /*
            if (objects.count > 1) {
                [self.swiperView setNumberOfDashes:i];
                [self addSubview:self.swiperView];
            }
            */
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
    [moviePlayer.view setFrame:CGRectMake(0,nameHeaderHeight,mainImageWidth,mainImageHeight)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setUserInteractionEnabled:NO];
    [moviePlayer.view setAlpha:1];
    [moviePlayer.backgroundView setBackgroundColor:[UIColor clearColor]];
    for(UIView *aSubView in moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setFrame:CGRectMake(VIDEOCGRECTFRAMECENTER(self.frame.size.width,73),
                                        (VIDEOCGRECTFRAMECENTER(self.frame.size.height-nameHeaderHeight-likeBarHeight,72))+nameHeaderHeight,73,72)];
    [self.playButton setBackgroundImage:IMAGE_PLAY_BUTTON forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setSelected:NO];
    
    [self addSubview:self.playButton];
    [self bringSubviewToFront:self.playButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
    
    [self addSubview:moviePlayer.view];
    [self bringSubviewToFront:moviePlayer.view];
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
                    NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                    if (postLocation) {
                        [locationLabel setUserInteractionEnabled:YES];
                        [locationLabel setText:postLocation];
                        [locationLabel setFont:BENDERSOLID(16)];
                        [locationLabel setBackgroundColor:[UIColor clearColor]];
                        [locationLabel setTextColor:[UIColor blackColor]];
                        
                        UITapGestureRecognizer *locationTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLocationAction:)];
                        locationTapRecognizer.numberOfTapsRequired = 1;
                        [locationLabel addGestureRecognizer:locationTapRecognizer];
                    }
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

- (void)didTapCommentButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapCommentButton:)]) {
        [delegate postDetailsHeaderView:self didTapCommentButton:button];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapMoreButton:)]) {
        [delegate postDetailsHeaderView:self didTapMoreButton:button];
    }
}

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
    [moviePlayer prepareToPlay];
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
