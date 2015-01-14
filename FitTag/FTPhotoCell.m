//
//  PhotoCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoCell.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTUtility.h"

@interface FTPhotoCell ()
@property (nonatomic, strong) UIButton *moreButton;
//@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
//@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end

@implementation FTPhotoCell
@synthesize photoButton;
//@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationLabel;
@synthesize distanceLabel;
//@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize commentCounter;
@synthesize likeCounter;
@synthesize moreButton;
//@synthesize usernameRibbon;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.opaque = NO;        
        self.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        CGSize frameSize = self.frame.size;
        
        self.imageView.frame = CGRectMake(0, 0, frameSize.width, frameSize.width);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = CONTENTMODE;
        self.imageView.clipsToBounds = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhotoButtonAction:)];
        singleTap.numberOfTapsRequired = 1;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake(0, 0, frameSize.width, frameSize.width);
        self.photoButton.backgroundColor = [UIColor clearColor];
        self.photoButton.clipsToBounds = YES;
        [self.photoButton addGestureRecognizer:singleTap];
        
        [self.contentView addSubview:self.photoButton];
        
        UIView *toolbar = [[UIView alloc] init];
        toolbar.frame = CGRectMake(0, self.photoButton.frame.size.height, frameSize.width, 60);
        toolbar.backgroundColor = FT_GRAY;
        
        [self.contentView addSubview:toolbar];
        
        FTPhotoCellButtons otherButtons = FTPhotoCellButtonsDefault;
        [FTPhotoCell validateButtons:otherButtons];
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
        
        if (self.buttons & FTPhotoCellButtonsComment) {
            
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
        
        if (self.buttons & FTPhotoCellButtonsLike) {
            
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
            //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_white"] forState:UIControlStateNormal];
            //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateSelected];
            //[self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart_selected"] forState:UIControlStateHighlighted];
            
            //[self.likeButton setBackgroundImage:HEART_UNSELECTED forState:UIControlStateNormal];
            //[self.likeButton setBackgroundImage:HEART_SELECTED forState:UIControlStateSelected];
            //[self.likeButton setBackgroundImage:HEART_SELECTED forState:UIControlStateHighlighted];
            
            [self.likeButton setBackgroundImage:ENCOURAGE_BUTTON_UNSELECTED forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:ENCOURAGE_BUTTON_SELECTED forState:UIControlStateSelected];
            [self.likeButton setBackgroundImage:ENCOURAGE_BUTTON_SELECTED forState:UIControlStateHighlighted];
            
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:NO];
            
            [toolbar addSubview:self.likeButton];
        }
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0,0,320,320);
    self.photoButton.frame = CGRectMake(0,0,320,320);
}

#pragma mark - FTPhotoCellView

- (void)setPhoto:(PFObject *)aPhoto {
    
    // reset text
    [locationLabel setText:EMPTY_STRING];
    
    photo = aPhoto;
    //NSLog(@"setPhoto FTPhotoViewCell::photo %@",photo);
    
    // User profile image
    PFUser *user = [self.photo objectForKey:kFTPostUserKey];
    //PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    //[self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    //CGFloat constrainWidth = containerView.bounds.size.width;
    
    /*
    if (self.buttons & FTPhotoCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    */
    
    if (self.buttons & FTPhotoCellButtonsComment){
        //constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTPhotoCellButtonsLike){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.likeCounter addTarget:self action:@selector(didTapLikeCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTPhotoCellButtonsMore){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([self.photo objectForKey:kFTPostPlaceKey]) {
        
        PFObject *place = [self.photo objectForKey:kFTPostPlaceKey];
        [place fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [locationLabel setText:[place objectForKey:kFTPlaceNameKey]];
                [locationLabel setUserInteractionEnabled:YES];
                
                UITapGestureRecognizer *locationTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLocationAction:)];
                locationTapRecognizer.numberOfTapsRequired = 1;
                [locationLabel addGestureRecognizer:locationTapRecognizer];
            }
        }];
        
        PFGeoPoint *geoPoint = [self.photo objectForKey:kFTPostLocationKey];
        
        // Calculate distance
        if (geoPoint && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
            CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            
            // Get the current users location
            PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
            CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
            
            // Current users distance to the item
            [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
        }
        /*
    } else if ([self.photo objectForKey:kFTPostLocationKey]) {
        
        PFGeoPoint *geoPoint = [self.photo objectForKey:kFTPostLocationKey];
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
        
        // Calculate distance
        if (geoPoint && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
            CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            
            // Get the current users location
            PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
            CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
            
            // Current users distance to the item
            [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
        }
         
         */
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
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)validateButtons:(FTPhotoCellButtons)buttons {
    if (buttons == FTPhotoCellButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapUserButton:user:)]) {
        [delegate photoCellView:self didTapUserButton:sender user:[self.photo objectForKey:kFTPostUserKey]];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapLikePhotoButton:counter:photo:)]) {
        [delegate photoCellView:self didTapLikePhotoButton:button counter:self.likeCounter photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoCellView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapMoreButton:photo:)]){
        [delegate photoCellView:self didTapMoreButton:sender photo:self.photo];
    }
}

- (void)didTapLocationAction:(FTPhotoCell *)sender {
    //NSLog(@"FTPhotoCell::didTapLocationAction");
    if (self.photo) {
        if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapLocation:photo:)]){
            [delegate photoCellView:self didTapLocation:sender photo:self.photo];
        }
    }
}

- (void)didTapPhotoButtonAction:(UIButton *)button {
    //NSLog(@"FTPhotoCell::didTapPhotoButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapPhotoButton:)]){
        [delegate photoCellView:self didTapPhotoButton:button];
    }
}

- (void)didTapLikeCountButtonAction:(UIButton *)button {
    NSLog(@"FTPhotoCell::didTapLikeCountButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapLikeCountButton:photo:)]){
        [delegate photoCellView:self didTapLikeCountButton:button photo:photo];
    }
}

@end

