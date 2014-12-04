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
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation FTVideoCell
@synthesize playButton;
@synthesize videoButton;
@synthesize userButton;
@synthesize locationLabel;
@synthesize timeIntervalFormatter;
@synthesize video;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize commentCounter;
@synthesize likeCounter;
@synthesize moreButton;
//@synthesize moviePlayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.superview.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapVideoButtonAction:)];
        singleTap.numberOfTapsRequired = 1;
        
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.videoButton.frame = CGRectMake(0, 0, self.frame.size.width, 320);
        self.videoButton.backgroundColor = [UIColor clearColor];
        self.videoButton.clipsToBounds = YES;
        
        [self.videoButton addGestureRecognizer:singleTap];
        [self.contentView addSubview:self.videoButton];
        
        UIView *videoCellButtonsContainer = [[UIView alloc] init];
        videoCellButtonsContainer.frame = CGRectMake(0,self.videoButton.frame.size.height,self.frame.size.width,30);
        videoCellButtonsContainer.backgroundColor = FT_GRAY;
        [self.contentView addSubview:videoCellButtonsContainer];
        
        FTVideoCellButtons otherButtons = FTVideoCellButtonsDefault;
        [FTVideoCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        //location label
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,BUTTONS_TOP_PADDING,120,20)];
        [locationLabel setText:EMPTY_STRING];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:[UIColor blackColor]];
        [locationLabel setFont:BENDERSOLID(16)];
        
        [videoCellButtonsContainer addSubview:locationLabel];
        
        if (self.buttons & FTVideoCellButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.likeButton setFrame:CGRectMake(locationLabel.frame.size.width + locationLabel.frame.origin.y, BUTTONS_TOP_PADDING, 21, 18)];
            [self.likeButton setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_white"] forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateSelected];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateHighlighted];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:NO];
            
            [videoCellButtonsContainer addSubview:self.likeButton];
            
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x, BUTTONS_TOP_PADDING, 37, 19)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
            [likeCounter setTitle:@"0" forState:UIControlStateNormal];
            [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
            [likeCounter.titleLabel setFont:BENDERSOLID(16)];
            [likeCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            [videoCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTVideoCellButtonsComment) {
            
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.commentButton setFrame:CGRectMake(likeCounter.frame.size.width + likeCounter.frame.origin.x, BUTTONS_TOP_PADDING, 21.0f, 18.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"comment_bubble"] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.commentButton setSelected:NO];
            
            [videoCellButtonsContainer addSubview:self.commentButton];
            
            commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [commentCounter setFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width, BUTTONS_TOP_PADDING, 37, 19)];
            [commentCounter setBackgroundColor:[UIColor clearColor]];
            [commentCounter setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [commentCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
            [commentCounter.titleLabel setFont:BENDERSOLID(16)];
            [commentCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [commentCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            [videoCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(self.frame.size.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
        
        [videoCellButtonsContainer addSubview:moreButton];
        
        // Play Button
        if (self.buttons & FTVideoCellButtonsPlay) {
            playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.playButton setFrame:CGRectMake(VIDEOCGRECTFRAMECENTER(self.videoButton.frame.size.width,73),
                                                 VIDEOCGRECTFRAMECENTER(self.videoButton.frame.size.height,72),73,72)];
            [self.playButton setBackgroundImage:IMAGE_PLAY_BUTTON forState:UIControlStateNormal];
            [self.playButton setSelected:NO];
            
            [videoButton addSubview:self.playButton];
            [videoButton bringSubviewToFront:self.playButton];
        }
    }    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 320, 320);
    self.videoButton.frame = CGRectMake(0, 0, 320, 320);
}

#pragma mark - FTVideoCellView

- (void)setVideo:(PFObject *)aVideo {    
    
    video = aVideo;
    
    // Get the profile image
    PFUser *user = [video objectForKey:kFTPostUserKey];
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    if (self.buttons & FTVideoCellButtonsPlay) {
        [self.playButton addTarget:self action:@selector(didTapVideoPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        //constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikeVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Location
    PFGeoPoint *geoPoint = [self.video objectForKey:kFTPostLocationKey];
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                for (CLPlacemark *placemark in placemarks) {
                    NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                    if (postLocation) {
                        [locationLabel setText:postLocation];
                        [locationLabel setUserInteractionEnabled:YES];
                        
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
        [locationLabel setText:EMPTY_STRING];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    [self.likeButton setSelected:liked];
    if (liked) {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0,0)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0,0)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self
                               action:@selector(didTapLikeVideoButtonAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self
                            action:@selector(didTapLikeVideoButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)validateButtons:(FTVideoCellButtons)buttons {
    if (buttons == FTVideoCellButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTVideoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    NSLog(@"FTVideoCell::didTapUserButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapUserButton:user:)]) {
        [delegate videoCellView:self didTapUserButton:sender user:[self.video objectForKey:kFTPostUserKey]];
    }
}

- (void)didTapLikeVideoButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapLikeVideoButton:counter:video:)]) {
        [delegate videoCellView:self didTapLikeVideoButton:button counter:self.likeCounter video:self.video];
    }
}

- (void)didTapCommentOnVideoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapCommentOnVideoButton:video:)]) {
        [delegate videoCellView:self didTapCommentOnVideoButton:sender video:self.video];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapMoreButton:video:)]){
        [delegate videoCellView:self didTapMoreButton:sender video:self.video];
    }
}


- (void)didTapVideoPlayButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapVideoPlayButton:video:)]){
        [delegate videoCellView:self didTapVideoPlayButton:sender video:video];
    }
    /*
    if (moviePlayer) {
        [moviePlayer prepareToPlay];
        [moviePlayer play];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Playback Error"
                                    message:@"Could not play video at this time. If the problem continues please yell at our developers by visiting settings > feedback"
                                   delegate:self
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    */
}

- (void)didTapLocationAction:(FTVideoCell *)sender {
    NSLog(@"FTVideoCell::didTapLocationAction");
    if (self.video) {
        if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapLocation:video:)]){
            [delegate videoCellView:self didTapLocation:sender video:self.video];
        }
    }
}

- (void)didTapVideoButtonAction:(UIButton *)button {
    NSLog(@"FTVideoCell::didTapVideoButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapVideoButton:)]){
        [delegate videoCellView:self didTapVideoButton:button];
    }
}

@end
