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
//@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end

@implementation FTPhotoCell
@synthesize photoButton;
//@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationLabel;
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
                
        self.imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.width);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = CONTENTMODE;
        self.imageView.clipsToBounds = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhotoButtonAction:)];
        singleTap.numberOfTapsRequired = 1;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.width);
        self.photoButton.backgroundColor = [UIColor clearColor];
        self.photoButton.clipsToBounds = YES;
        [self.photoButton addGestureRecognizer:singleTap];
        
        [self.contentView addSubview:self.photoButton];
        
        UIView *photoCellButtonsContainer = [[UIView alloc] init];
        photoCellButtonsContainer.frame = CGRectMake(0,self.photoButton.frame.size.height,self.frame.size.width,30);
        photoCellButtonsContainer.backgroundColor = FT_GRAY;
        
        [self.contentView addSubview:photoCellButtonsContainer];
        
        FTPhotoCellButtons otherButtons = FTPhotoCellButtonsDefault;
        [FTPhotoCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        //location label
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,BUTTONS_TOP_PADDING,120,20)];
        [locationLabel setText:EMPTY_STRING];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:[UIColor blackColor]];
        [locationLabel setFont:BENDERSOLID(16)];
        
        [photoCellButtonsContainer addSubview:locationLabel];
        
        if (self.buttons & FTPhotoCellButtonsLike) {
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
            
            [photoCellButtonsContainer addSubview:self.likeButton];
            
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x, BUTTONS_TOP_PADDING, 37.0f, 19.0f)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
            [likeCounter setTitle:@"0" forState:UIControlStateNormal];
            [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1,1,-1,-1)];
            [likeCounter.titleLabel setFont:BENDERSOLID(16)];
            [likeCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            [photoCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTPhotoCellButtonsComment) {
            
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
            
            [photoCellButtonsContainer addSubview:self.commentButton];
            
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
            
            [photoCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(self.frame.size.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
        
        [photoCellButtonsContainer addSubview:moreButton];
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
    }
    
    if (self.buttons & FTPhotoCellButtonsMore){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //Location
    PFGeoPoint *geoPoint = [self.photo objectForKey:kFTPostLocationKey];
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
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

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

- (void)didTapUserButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapUserButton:user:)]) {
        [delegate photoCellView:self didTapUserButton:sender user:[self.photo objectForKey:kFTPostUserKey]];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button{
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapLikePhotoButton:counter:photo:)]) {
        [delegate photoCellView:self didTapLikePhotoButton:button counter:self.likeCounter photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoCellView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapMoreButton:photo:)]){
        [delegate photoCellView:self didTapMoreButton:sender photo:self.photo];
    }
}

- (void)didTapLocationAction:(FTPhotoCell *)sender {
    NSLog(@"FTPhotoCell::didTapLocationAction");
    if (self.photo) {
        if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapLocation:photo:)]){
            [delegate photoCellView:self didTapLocation:sender photo:self.photo];
        }
    }
}

- (void)didTapPhotoButtonAction:(UIButton *)button {
    NSLog(@"FTPhotoCell::didTapPhotoButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapPhotoButton:)]){
        [delegate photoCellView:self didTapPhotoButton:button];
    }
}
@end

