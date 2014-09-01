//
//  FTVideoCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/31/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTVideoCell.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTUtility.h"

@interface FTVideoCell ()
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end

@implementation FTVideoCell
@synthesize playButton;
@synthesize videoButton;
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize video;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize commentCounter;
@synthesize likeCounter;
@synthesize moreButton;
@synthesize usernameRibbon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.videoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.videoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.videoButton];
        
        UIView *videoCellButtonsContainer = [[UIView alloc] init];
        videoCellButtonsContainer.frame = CGRectMake(120.0f, 295.0f, 200.0f, 22.0f);
        videoCellButtonsContainer.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:videoCellButtonsContainer];
        
        FTVideoCellButtons otherButtons = FTVideoCellButtonsDefault;
        [FTVideoCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = YES;
        self.containerView.clipsToBounds = YES;
        self.superview.clipsToBounds = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *profileHexagon = [self getProfileHexagon];
        
        self.avatarImageView = [[FTProfileImageView alloc] init];
        self.avatarImageView.frame = profileHexagon.frame;
        self.avatarImageView.layer.mask = profileHexagon.layer.mask;
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageView];
        
        //username_ribbon
        self.usernameRibbon = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [FTVideoCell imageWithImage:[UIImage imageNamed:@"username_ribbon"] scaledToSize:CGSizeMake(88.0f, 20.0f)];
        [self.usernameRibbon setBackgroundColor:[UIColor colorWithPatternImage:image]];
        self.usernameRibbon.frame = CGRectMake(self.avatarImageView.frame.size.width + self.avatarImageView.frame.origin.x - 4,
                                               self.avatarImageView.frame.origin.y + 10,88.0f, 20.0f);
        
        [self.usernameRibbon addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.usernameRibbon setTitle:@"" forState:UIControlStateNormal];
        [self.usernameRibbon.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        self.usernameRibbon.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.usernameRibbon.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self.contentView addSubview:self.usernameRibbon];
        [self.contentView bringSubviewToFront:self.avatarImageView];
        
        // Play Button
        if (self.buttons & FTVideoCellButtonsPlay) {
            float centerX = (self.videoButton.frame.size.width - 60) / 2;
            float centerY = (self.videoButton.frame.size.height - 60) / 2;
            playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.playButton setFrame:CGRectMake(centerX,centerY,60.0f,60.0f)];
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
            [self.playButton setSelected:NO];
            [self.contentView addSubview:self.playButton];
            [self.contentView bringSubviewToFront:self.playButton];
        }
        
        if (self.buttons & FTVideoCellButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [videoCellButtonsContainer addSubview:self.likeButton];
            [self.likeButton setFrame:CGRectMake(5.0f, 1.0f, 21.0f, 18.0f)];
            [self.likeButton setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:@"" forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_white"] forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateSelected];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:NO];
            
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x + 3.0f, likeButton.frame.origin.y, 37.0f, 19.0f)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
            [likeCounter setTitle:@"0" forState:UIControlStateNormal];
            [likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [videoCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTVideoCellButtonsComment) {
            
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [videoCellButtonsContainer addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake(likeCounter.frame.size.width + likeCounter.frame.origin.x + 15.0f, likeCounter.frame.origin.y, 21.0f, 18.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"comment_bubble"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
            
            commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [commentCounter setFrame: CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 3.0f, self.commentButton.frame.origin.y, 37.0f, 19.0f)];
            [commentCounter setBackgroundColor:[UIColor clearColor]];
            [commentCounter setTitle:@"" forState:UIControlStateNormal];
            [commentCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [videoCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(commentCounter.frame.size.width + commentCounter.frame.origin.x + 15.0f, commentCounter.frame.origin.y, 35.0f, 19.0f)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:@"" forState:UIControlStateNormal];
        [videoCellButtonsContainer addSubview:moreButton];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
    self.videoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
}

#pragma mark - FTVideoCellView

- (void)setVideo:(PFObject *)aVideo {
    video = aVideo;
    
    // user's avatar
    PFUser *user = [self.video objectForKey:kFTVideoUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    PFFile *videoFile = [video objectForKey:kFTVideoKey];
    NSURL *url = [NSURL URLWithString:videoFile.url];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
    [self.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [self.moviePlayer setContentURL:url];
    [self.moviePlayer.view setFrame:CGRectMake(0.0f,0.0f,320.0f,320.0f)];
    [self.moviePlayer requestThumbnailImagesAtTimes:@[ @0.1f, @1.0f ] timeOption:MPMovieTimeOptionExact];
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer setFullscreen:YES];
    [self.moviePlayer.view setHidden:YES];
    [self.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallBack)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerStateChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayer];

    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    
    CGFloat constrainWidth = containerView.bounds.size.width;

    [self.avatarImageView setFile:profilePictureSmall];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    if (self.buttons & FTVideoCellButtonsPlay) {
        [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikeVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    [self.likeButton setSelected:liked];
    
    if (liked) {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikeVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikeVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

- (UIImageView *)getProfileHexagon{
    
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

+ (void)validateButtons:(FTVideoCellButtons)buttons {
    if (buttons == FTVideoCellButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTVideoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapUserButton:user:)]) {
        [delegate videoCellView:self didTapUserButton:sender user:[self.video objectForKey:kFTVideoUserKey]];
    }
}

- (void)didTapLikeVideoButtonAction:(UIButton *)button{
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapLikeVideoButton:counter:video:)]) {
        [delegate videoCellView:self didTapLikeVideoButton:button counter:self.likeCounter video:self.video];
    }
}

- (void)didTapCommentOnVideoButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapCommentOnVideoButton:video:)]) {
        [delegate videoCellView:self didTapCommentOnVideoButton:sender video:self.video];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapMoreButton:video:)]){
        [delegate videoCellView:self didTapMoreButton:sender video:self.video];
    }
}

- (void)didTapVideoPlayButtonAction:(UIButton *)sender{
    [self.playButton setHidden:YES];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer requestThumbnailImagesAtTimes:@[ @0.1f, @1.0f ] timeOption:MPMovieTimeOptionExact];
    [self.moviePlayer play];
}

-(void)movieFinishedCallBack{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];
}

-(void)moviePlayerStateChange:(NSNotification *)notification{
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying){
        //NSLog(@"moviePlayer... Playing");
        [self.imageView addSubview:self.moviePlayer.view];
        [self.moviePlayer.view setHidden:NO];
    }
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStateStopped){
        //NSLog(@"moviePlayer... Stopped");
        [self.moviePlayer stop];
        [self.playButton setHidden:NO];
        [self.moviePlayer.view setHidden:YES];
        [self.moviePlayer.view removeFromSuperview];
    }
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused){
        //NSLog(@"moviePlayer... Paused");
        [self.moviePlayer stop];
    }
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted){
        //NSLog(@"moviePlayer... Interrupted");
        [self.moviePlayer stop];
    }
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward){
        //NSLog(@"moviePlayer... Forward");
    }
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward){
        //NSLog(@"moviePlayer... Backward");
    }
}

@end
