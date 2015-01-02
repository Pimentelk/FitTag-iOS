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
#import "STTweetLabel.h"

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
#define avatarImageDim 33.0f

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

//#define likeButtonX 9.0f
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
@property (nonatomic, strong) UIButton *userButton;
// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *photographer;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) STTweetLabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property CGFloat captionHeight;

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
@synthesize likeCounter;
@synthesize commentCounter;
@synthesize commentButton;
@synthesize moreButton;
@synthesize carousel;
@synthesize swiperView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationLabel;
@synthesize contentLabel;
@synthesize captionHeight;
@synthesize timeLabel;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost
               type:(NSString *)aType {
    
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
        
        self.backgroundColor = [UIColor whiteColor];
        [self createView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost
               type:(NSString *)aType
       photographer:(PFUser*)aPhotographer
          likeUsers:(NSArray*)theLikeUsers {
    
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
        
        self.backgroundColor = [UIColor whiteColor];
        
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

+ (CGRect)rectForView {
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [FTPostDetailsHeaderView heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = CGSizeMake(0, 0);
    nameSize = [name boundingRectWithSize:nameSize
                                  options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                  context:nil].size;
    
    NSString *paddedString = [FTPostDetailsHeaderView padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [FTPostDetailsHeaderView horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGFloat singleLineHeight = [@"test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarImageDim + horiMediumSpacing + multilineHeightAddition;
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        CGSize resultSize = [paddedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                                       context:nil].size;
        if (resultSize.width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarImageDim+horiBorderSpacing+horiBorderSpacing);
}

#pragma mark - FTPhotoDetailsHeaderView

- (void)setPost:(PFObject *)aPost {
    post = aPost;
    
    if (self.post && self.photographer && self.likeUsers && self.type) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void)setDate:(NSDate *)date {
    if (date) {
        
        NSString *time = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
        NSDictionary *userAttributes = @{NSFontAttributeName: BENDERSOLID(14)};
        CGSize stringBoundingBox = [time sizeWithAttributes:userAttributes];
        
        CGFloat frameWidth = self.frame.size.width;
        CGFloat padding = 15;
        
        [self.timeLabel setFrame:CGRectMake(frameWidth-stringBoundingBox.width-padding, 0, stringBoundingBox.width, nameHeaderHeight)];
        
        [self.timeLabel setText:time];
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
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
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
            //NSLog(@"moviePlayer... MPMovieLoadStatePlayable");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMovieLoadStatePlaythroughOK: {
            //NSLog(@"moviePlayer... MPMovieLoadStatePlaythroughOK");
            
        }
            break;
        case MPMovieLoadStateStalled: {
            //NSLog(@"moviePlayer... MPMovieLoadStateStalled");
            
        }
            break;
        case MPMovieLoadStateUnknown: {
            //NSLog(@"moviePlayer... MPMovieLoadStateUnknown");
            
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
            //NSLog(@"moviePlayer... MPMoviePlaybackStateStopped");
            
        }
            break;
        case MPMoviePlaybackStatePlaying: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
            //NSLog(@"moviePlayer... MPMovieLoadStatePlayable");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMoviePlaybackStatePaused: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePaused");
            [UIView animateWithDuration:0.3 animations:^{
                [moviePlayer.view setAlpha:0];
                [moviePlayer prepareToPlay];
            }];
        }
            break;
        case MPMoviePlaybackStateInterrupted: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateInterrupted");
            
        }
            break;
        case MPMoviePlaybackStateSeekingForward: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingForward");
            
        }
            break;
        case MPMoviePlaybackStateSeekingBackward: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingBackward");
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > (scrollView.contentSize.width - self.frame.size.width))
        [self killScroll];
    
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        if (previousPage < page) {
            [self.swiperView onGallerySwipedLeft:page];
        } else if (previousPage > page) {
            [self.swiperView onGallerySwipedRight:page];
        }
        previousPage = page;
    }
}

#pragma mark - ()

- (void)createView {
    
    self.clipsToBounds = YES;
    self.nameHeaderView.clipsToBounds = YES;
    self.superview.clipsToBounds = YES;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    // Create middle section of the header view; the image
    
    self.postImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
    self.postImageView.backgroundColor = [UIColor whiteColor];
    self.postImageView.clipsToBounds = YES;
    
    PFFile *imageFile = [self.post objectForKey:kFTPostImageKey];
    if (imageFile) {
        self.postImageView.file = imageFile;
        [self.postImageView loadInBackground];
    }
    
    // set config depending on post type
    
    if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeGallery]) {
        self.postImageView.contentMode = CONTENTMODE;
        [self addSubview:self.postImageView];
        [self configGallery:self.post];
    } else if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeVideo]) {
        self.postImageView.contentMode = CONTENTMODEVIDEO;
        [self addSubview:self.postImageView];
        [self configVideo:self.post];
    } else if ([[self.post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeImage]) {
        self.postImageView.contentMode = CONTENTMODE;
        [self addSubview:self.postImageView];
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
    
    CGSize frameSize = self.frame.size;
    
    UIView *toolbar = [[UIView alloc] init];
    toolbar.frame = CGRectMake(0, mainImageHeight + nameHeaderHeight, frameSize.width, likeBarHeight);
    toolbar.backgroundColor = FT_GRAY;
    
    [self addSubview:toolbar];
    
    //location label
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, BUTTONS_TOP_PADDING, 130, 20)];
    [locationLabel setText:EMPTY_STRING];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [locationLabel setTextColor:FT_RED];
    [locationLabel setFont:BENDERSOLID(13)];
    
    [toolbar addSubview:locationLabel];
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
    [moreButton setBackgroundImage:MORE_BUTTON forState:UIControlStateNormal];
    [moreButton setFrame:CGRectMake(frameSize.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
    [moreButton setBackgroundColor:[UIColor clearColor]];
    [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat commentCounterX = moreButton.frame.origin.x - COUNTER_WIDTH - BUTTON_PADDING;
    
    commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentCounter setFrame:CGRectMake(commentCounterX, BUTTONS_TOP_PADDING, COUNTER_WIDTH, COUNTER_HEIGHT)];
    [commentCounter setBackgroundColor:[UIColor clearColor]];
    //[commentCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
    [commentCounter setBackgroundImage:COUNTER_BOX forState:UIControlStateNormal];
    [commentCounter setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [commentCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
    [commentCounter.titleLabel setFont:BENDERSOLID(18)];
    [commentCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [commentCounter setTitleColor:FT_RED forState:UIControlStateNormal];
    [commentCounter setTitleColor:FT_RED forState:UIControlStateSelected];
    [commentCounter setTitleColor:FT_RED forState:UIControlStateHighlighted];
    
    [toolbar addSubview:commentCounter];
    
    CGFloat commentButtonX = commentCounterX - BUTTON_WIDTH;
    
    // comments button
    commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setFrame:CGRectMake(commentButtonX, BUTTONS_TOP_PADDING, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.commentButton setBackgroundColor:[UIColor clearColor]];
    //[self.commentButton setBackgroundImage:[UIImage imageNamed:@"comment_bubble"] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(didTapCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setBackgroundImage:COMMENT_BUBBLE forState:UIControlStateNormal];
    [self.commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.commentButton setSelected:NO];
    
    [toolbar addSubview:self.commentButton];
    
    CGFloat likeCounterX = commentButton.frame.origin.x - COUNTER_WIDTH - BUTTON_PADDING;
    
    // like counter
    likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeCounter setFrame:CGRectMake(likeCounterX, BUTTONS_TOP_PADDING, COUNTER_WIDTH, COUNTER_HEIGHT)];
    [likeCounter setBackgroundColor:[UIColor clearColor]];
    [likeCounter addTarget:self action:@selector(didTapLikeCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //[likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
    [likeCounter setBackgroundImage:COUNTER_BOX forState:UIControlStateNormal];
    [likeCounter setTitle:@"0" forState:UIControlStateNormal];
    [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
    [likeCounter.titleLabel setFont:BENDERSOLID(18)];
    [likeCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [likeCounter setTitleColor:FT_RED forState:UIControlStateNormal];
    [likeCounter setTitleColor:FT_RED forState:UIControlStateSelected];
    [likeCounter setTitleColor:FT_RED forState:UIControlStateHighlighted];
    
    [toolbar addSubview:likeCounter];
    
    CGFloat likeButtonX = likeCounterX - BUTTON_WIDTH;
    
    // like button
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:CGRectMake(likeButtonX, BUTTONS_TOP_PADDING, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.likeButton setBackgroundColor:[UIColor clearColor]];
    [self.likeButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_white"] forState:UIControlStateNormal];
    //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateSelected];
    //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateHighlighted];
    
    [self.likeButton setBackgroundImage:HEART_UNSELECTED forState:UIControlStateNormal];
    [self.likeButton setBackgroundImage:HEART_SELECTED forState:UIControlStateSelected];
    [self.likeButton setBackgroundImage:HEART_SELECTED forState:UIControlStateHighlighted];
    
    [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.likeButton setSelected:NO];
    
    [toolbar addSubview:self.likeButton];
    
    [toolbar addSubview:moreButton];
    [self bringSubviewToFront:toolbar];
    [self reloadLikeBar];
    
    if ([self.post objectForKey:kFTPostCaptionKey]) {
        [self.photographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                self.photographer = (PFUser *)object;
                
                NSString *name = [self.photographer objectForKey:kFTUserDisplayNameKey];
                NSString *contentString = [self.post objectForKey:kFTPostCaptionKey];
                captionHeight = [FTPostDetailsHeaderView heightForCellWithName:name contentString:contentString];
                
                CGRect captionRect = toolbar.frame;
                captionRect.origin.y += captionRect.size.height;
                captionRect.size.height = captionHeight;
                
                // Background
                
                UIView *captionView = [[UIView alloc] initWithFrame:captionRect];
                [captionView setBackgroundColor:FT_GRAY];
                [self addSubview:captionView];
                
                // UILabel
                self.contentLabel = [[STTweetLabel alloc] init];
                [self.contentLabel setFont:[UIFont systemFontOfSize:13]];
                [self.contentLabel setTextColor:[UIColor colorWithRed:73./255. green:55./255. blue:35./255. alpha:1.000]];
                [self.contentLabel setNumberOfLines:0];
                [self.contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [self.contentLabel setBackgroundColor:[UIColor clearColor]];
                [self.contentLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.70f]];
                [self.contentLabel setShadowOffset:CGSizeMake(0,1)];
                [self.contentLabel setText:contentString];
                [self.contentLabel setFrame:CGRectMake(5, 5, captionView.bounds.size.width-10, captionView.bounds.size.height-10)];
                [self.contentLabel setUserInteractionEnabled:YES];
                [captionView addSubview:self.contentLabel];
                __unsafe_unretained typeof(self) weakSelf = self;
                
                [self.contentLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
                    NSArray *hotWords = @[ HOTWORD_HANDLE, HOTWORD_HASHTAG, HOTWORD_LINK ];
                    if ([hotWords[hotWord] isEqualToString:HOTWORD_HANDLE]) {
                        NSLog(@"didTapUserMention:%@",string);
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserMention:)]) {
                            [weakSelf.delegate postDetailsHeaderView:weakSelf didTapUserMention:string];
                        }
                    } else if ([hotWords[hotWord] isEqualToString:HOTWORD_HASHTAG]) {
                        NSLog(@"didTapHashTag:%@",string);
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(postDetailsHeaderView:didTapHashTag:)]) {
                            [weakSelf.delegate postDetailsHeaderView:weakSelf didTapHashTag:string];
                        }
                    } else if ([hotWords[hotWord] isEqualToString:HOTWORD_LINK]) {
                        
                    }
                }];
            }
        }];
    }
}

#pragma mark - config

- (void)configHeader:(PFObject *)aPhotographer {
    [aPhotographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            avatarImageView = [[FTProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
            [avatarImageView setFile:[self.photographer objectForKey:kFTUserProfilePicSmallKey]];
            [avatarImageView setBackgroundColor:[UIColor clearColor]];
            [avatarImageView setUserInteractionEnabled:YES];
            [avatarImageView setFrame:CGRectMake(AVATAR_X,AVATAR_Y,AVATAR_WIDTH,AVATAR_HEIGHT)];
            [avatarImageView.layer setCornerRadius:CORNERRADIUS(AVATAR_WIDTH)];
            [avatarImageView setClipsToBounds:YES];
            [avatarImageView.profileButton addTarget:self
                                              action:@selector(didTapUserButtonAction:)
                                    forControlEvents:UIControlEventTouchUpInside];
            
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [self.userButton setTitleColor:FT_RED forState:UIControlStateNormal];
            [self.userButton setTitleColor:FT_DARKGRAY forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setFont:BENDERSOLID(18)];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            [[self.userButton titleLabel] setShadowOffset:CGSizeMake(0,1)];
            [self.userButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.750f] forState:UIControlStateNormal];
            [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.userButton setTitle:[self.photographer objectForKey:kFTUserDisplayNameKey] forState:UIControlStateNormal];
            
            // we resize the button to fit the user's name to avoid having a huge touch area
            CGFloat constrainWidth = self.frame.size.width;
            CGFloat userButtonPointWidth = AVATAR_X + AVATAR_WIDTH + 9;
            CGFloat userButtonPointHeight = (nameHeaderHeight - 12) / 2;
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
            
            self.timeLabel = [[UILabel alloc] init];
            [self.timeLabel setFont:BENDERSOLID(14)];
            [self.timeLabel setTextColor:[UIColor lightGrayColor]];
            [self.timeLabel setBackgroundColor:[UIColor clearColor]];
            [self.timeLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.70f]];
            [self.timeLabel setShadowOffset:CGSizeMake(0, 1)];
            [self.timeLabel setText:EMPTY_STRING];
            [self setDate:[self.post createdAt]];
            
            [self addSubview:self.timeLabel];
            
            [self setNeedsDisplay];
        }
    }];
}

- (void)configGallery:(PFObject *)aGallery {
    NSLog(@"%@::configGallery",VIEWCONTROLLER_POST_HEADER);
    [PFObject fetchAllIfNeededInBackground:[aGallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            CGSize frameSize = self.frame.size;
            
            carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, nameHeaderHeight, frameSize.width, 320)];
            [carousel setUserInteractionEnabled:YES];
            [carousel setDelaysContentTouches:YES];
            [carousel setExclusiveTouch:YES];
            [carousel setCanCancelContentTouches:YES];
            [carousel setBackgroundColor:[UIColor whiteColor]];
            [carousel setDelegate:self];
            [carousel setPagingEnabled:YES];
            [carousel setAlwaysBounceVertical:NO];
            
            swiperView = [[FTGallerySwiperView alloc] init];
            [swiperView setFrame:CGRectMake(0, 0, (16 * objects.count), 20)];
            
            //CGFloat swiperCenterY = frameSize.height-likeBarHeight-5-captionHeight;
            CGFloat swiperCenterY = nameHeaderHeight + carousel.frame.size.height - 5;
            
            [swiperView setCenter:CGPointMake(frameSize.width/2, swiperCenterY)];
            
            int i = 0;
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:kFTPostImageKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {                        
                        CGFloat xOrigin = i * self.frame.size.width;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, frameSize.width, frameSize.width)];
                        [imageView setBackgroundColor:[UIColor whiteColor]];
                        
                        UIImage *image = [UIImage imageWithData:data];
                        [imageView setImage:image];
                        [imageView setClipsToBounds:YES];
                        [imageView setContentMode:CONTENTMODE];
                        [imageView setUserInteractionEnabled:YES];
                        
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
            
            if (objects.count > 1) {
                [self.swiperView setNumberOfDashes:i];
                [self addSubview:self.swiperView];
            }
            
            
            [carousel setContentSize:CGSizeMake(self.frame.size.width * objects.count, self.frame.size.width)];
            //[self performSelector:@selector(showCarousel) withObject:nil afterDelay:1];
        }
    }];
}

- (void)showCarousel {
    [UIView animateWithDuration:0.2 animations:^{
        [carousel setAlpha:1];
    }];
}

- (void)configVideo:(PFObject *)aPost {
    NSLog(@"%@::configVideo:",VIEWCONTROLLER_POST_HEADER);
    
    // setup the video player
    PFFile *videoFile = [aPost objectForKey:kFTPostVideoKey];
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer setScalingMode:SCALINGMODE];
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
                        UITapGestureRecognizer *locationTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLocationAction:)];
                        locationTapRecognizer.numberOfTapsRequired = 1;
                        [locationLabel addGestureRecognizer:locationTapRecognizer];
                        [locationLabel setUserInteractionEnabled:YES];
                        [locationLabel setText:postLocation];
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
    [self setLikeButtonState:liked];
    
    [button removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [button setEnabled:NO];
    if (liked) {
        [FTUtility likePhotoInBackground:self.post block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
                [button setEnabled:YES];
            }
            if (error) {
                NSLog(@"Like error:%@",error);
            }
            
            if (succeeded) {
                [button setEnabled:YES];
            }
        }];
    } else {
        [FTUtility unlikePhotoInBackground:self.post block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
                [button setEnabled:YES];
            }
            
            if (error) {
                NSLog(@"Like error:%@",error);
            }
            
            if (succeeded) {
                [button setEnabled:YES];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FTPostDetailsViewControllerUserLikedUnlikedPhotoNotification
                                                        object:self.post
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked]
                                                                                           forKey:FTPostDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapLikerButtonAction:");
    PFUser *user = [self.likeUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate postDetailsHeaderView:self didTapUserButton:button user:user];
    }
}

- (void)didTapUserButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapUserButtonAction:");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate postDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    }
}

- (void)didTapLikeCountButtonAction:(UIButton *)button {
    NSLog(@"FTPostDetailsHeaderView::didTapLikeCountButtonAction:");
    if (delegate && [delegate respondsToSelector:@selector(postDetailsHeaderView:didTapLikeCountButton:post:)]) {
        [delegate postDetailsHeaderView:self didTapLikeCountButton:button post:self.post];
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
