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
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation FTVideoCell
@synthesize playButton;
@synthesize videoButton;
@synthesize userButton;
@synthesize locationLabel;
@synthesize distanceLabel;
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
        
        CGSize frameSize = self.frame.size;
        
        UIView *toolbar = [[UIView alloc] init];
        toolbar.frame = CGRectMake(0, self.videoButton.frame.size.height, frameSize.width, 60);
        toolbar.backgroundColor = FT_GRAY;
        
        [self.contentView addSubview:toolbar];
        
        FTVideoCellButtons otherButtons = FTVideoCellButtonsDefault;
        [FTVideoCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        //location label
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, BUTTONS_TOP_PADDING+30, 240, 20)];
        [locationLabel setText:EMPTY_STRING];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:FT_RED];
        [locationLabel setFont:MULIREGULAR(13)];
        
        [toolbar addSubview:locationLabel];
        
        //distance label
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(toolbar.frame.size.width-80, BUTTONS_TOP_PADDING+30, 80, 20)];
        [distanceLabel setText:EMPTY_STRING];
        [distanceLabel setBackgroundColor:[UIColor clearColor]];
        [distanceLabel setTextColor:FT_RED];
        [distanceLabel setFont:MULIREGULAR(13)];
        
        [toolbar addSubview:distanceLabel];
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setBackgroundImage:MORE_BUTTON forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(frameSize.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
        
        [toolbar addSubview:moreButton];
        
        if (self.buttons & FTVideoCellButtonsComment) {
            
            CGFloat commentCounterX = moreButton.frame.origin.x - COUNTER_WIDTH - BUTTON_PADDING;
            
            commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [commentCounter setFrame:CGRectMake(commentCounterX, BUTTONS_TOP_PADDING, COUNTER_WIDTH, COUNTER_HEIGHT)];
            [commentCounter setBackgroundColor:[UIColor clearColor]];
            //[commentCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [commentCounter setBackgroundImage:COUNTER_BOX forState:UIControlStateNormal];
            [commentCounter setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [commentCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
            [commentCounter.titleLabel setFont:MULIREGULAR(18)];
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
            //[self.commentButton setBackgroundImage:COMMENT_BUBBLE forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage:COMMENT_BUTTON forState:UIControlStateNormal];
            [self.commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.commentButton setSelected:NO];
            
            [toolbar addSubview:self.commentButton];
        }
        
        if (self.buttons & FTVideoCellButtonsLike) {
            
            CGFloat likeCounterX = commentButton.frame.origin.x - COUNTER_WIDTH - BUTTON_PADDING;
            
            // like counter
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeCounterX, BUTTONS_TOP_PADDING, COUNTER_WIDTH, COUNTER_HEIGHT)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
            //[likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [likeCounter setBackgroundImage:COUNTER_BOX forState:UIControlStateNormal];
            [likeCounter setTitle:@"0" forState:UIControlStateNormal];
            [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
            [likeCounter.titleLabel setFont:MULIREGULAR(18)];
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
            
            [self.likeButton setBackgroundImage:INSPIRED_BUTTON_UNSELECTED forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:INSPIRED_BUTTON_SELECTED forState:UIControlStateSelected];
            [self.likeButton setBackgroundImage:INSPIRED_BUTTON_SELECTED forState:UIControlStateHighlighted];
            
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:NO];
            
            [toolbar addSubview:self.likeButton];
        }
        
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
        [self.likeCounter addTarget:self action:@selector(didTapLikeCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTVideoCellButtonsUser){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([self.video objectForKey:kFTPostPlaceKey]) {
        
        PFObject *place = [self.video objectForKey:kFTPostPlaceKey];
        [place fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                // Check if the place has a geopoint associated with it
                if ([place objectForKey:kFTPlaceLocationKey]) {
                    
                    // Set the name for this location
                    [locationLabel setText:[place objectForKey:kFTPlaceNameKey]];
                    [locationLabel setUserInteractionEnabled:YES];
                    
                    // When tapped show this location on the map
                    UITapGestureRecognizer *locationTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLocationAction:)];
                    locationTapRecognizer.numberOfTapsRequired = 1;
                    [locationLabel addGestureRecognizer:locationTapRecognizer];
                    
                    // Calculate distance
                    PFGeoPoint *geoPoint = [place objectForKey:kFTPlaceLocationKey];
                    if (geoPoint && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
                        CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                        
                        // Get the current users location
                        PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
                        CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
                        
                        // Current users distance to the item
                        [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
                    }
                }
            }
        }];
        
    } else {
        [locationLabel setText:EMPTY_STRING];
        [distanceLabel setText:EMPTY_STRING];
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

- (CLLocationDistance)distanceFrom:(CLLocation *)postLocation to:(CLLocation *)userLocation {
    return [postLocation distanceFromLocation:userLocation];
}

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
}

- (void)didTapLocationAction:(FTVideoCell *)sender {
    //NSLog(@"FTVideoCell::didTapLocationAction");
    if (self.video) {
        if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapLocation:video:)]){
            [delegate videoCellView:self didTapLocation:sender video:self.video];
        }
    }
}

- (void)didTapVideoButtonAction:(UIButton *)button {
    //NSLog(@"FTVideoCell::didTapVideoButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapVideoButton:)]){
        [delegate videoCellView:self didTapVideoButton:button];
    }
}

- (void)didTapLikeCountButtonAction:(UIButton *)button {
    //NSLog(@"FTVideoCell::didTapVideoButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(videoCellView:didTapLikeCountButton:video:)]){
        [delegate videoCellView:self didTapLikeCountButton:button video:video];
    }
}

@end
