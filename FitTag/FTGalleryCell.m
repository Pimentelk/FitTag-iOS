//
//  FTGalleryCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTGalleryCell.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTUtility.h"
#import "FTGallerySwiperView.h"

#define EXTRA_PADDING 3
#define REMOVE_EXTRA_PADDING 4

@interface FTGalleryCell ()
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIView *containerView;
//@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) FTGallerySwiperView *swiperView;
@end

@implementation FTGalleryCell
@synthesize galleryButton;
@synthesize containerView;
//@synthesize avatarImageView;
@synthesize userButton;
@synthesize locationLabel;
@synthesize timeIntervalFormatter;
@synthesize gallery;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize commentCounter;
@synthesize likeCounter;
@synthesize moreButton;
//@synthesize usernameRibbon;
@synthesize carousel;
@synthesize swiperView;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.superview.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, 320);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = CONTENTMODE;
        
        self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.galleryButton.frame = CGRectMake(0, 0, self.frame.size.width, 320);
        self.galleryButton.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.galleryButton];
        
        UIView *galleryCellButtonsContainer = [[UIView alloc] init];
        galleryCellButtonsContainer.frame = CGRectMake(0, self.galleryButton.frame.size.height, self.frame.size.width, 30);
        galleryCellButtonsContainer.backgroundColor = FT_GRAY;
        [self.contentView addSubview:galleryCellButtonsContainer];
        
        FTGalleryCellButtons otherButtons = FTGalleryCellButtonsDefault;
        [FTGalleryCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        //location label
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, BUTTONS_TOP_PADDING, 120, 20)];
        [locationLabel setText:EMPTY_STRING];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:[UIColor blackColor]];
        [locationLabel setFont:BENDERSOLID(16)];
        
        [galleryCellButtonsContainer addSubview:locationLabel];
        
        if (self.buttons & FTGalleryCellButtonsLike) {
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
            
            [galleryCellButtonsContainer addSubview:self.likeButton];
            
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeButton.frame.size.width + likeButton.frame.origin.x, BUTTONS_TOP_PADDING, 37, 19)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
            [likeCounter setTitle:@"0" forState:UIControlStateNormal];
            [likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(1, 1, -1, -1)];
            [likeCounter.titleLabel setFont:BENDERSOLID(16)];
            [likeCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [likeCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [likeCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            [galleryCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTGalleryCellButtonsComment) {
            
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.commentButton setFrame:CGRectMake(likeCounter.frame.size.width + likeCounter.frame.origin.x, BUTTONS_TOP_PADDING, 21, 18)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"comment_bubble"] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.commentButton setSelected:NO];
            
            [galleryCellButtonsContainer addSubview:self.commentButton];
            
            commentCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [commentCounter setFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width, BUTTONS_TOP_PADDING, 37, 19)];
            [commentCounter setBackgroundColor:[UIColor clearColor]];
            [commentCounter setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [commentCounter setTitleEdgeInsets:UIEdgeInsetsMake(1, 1, -1, -1)];
            [commentCounter.titleLabel setFont:BENDERSOLID(16)];
            [commentCounter.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [commentCounter setBackgroundImage:[UIImage imageNamed:@"like_comment_box"] forState:UIControlStateNormal];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [commentCounter setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            [galleryCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(self.frame.size.width - 45, BUTTONS_TOP_PADDING, 35, 19)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
        [galleryCellButtonsContainer addSubview:moreButton];
        
        swiperView = [[FTGallerySwiperView alloc] initWithFrame:CGRectMake(10, 5, 60, 20)];
        
        carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 320)];
        [carousel setDelegate:self];
        [carousel setUserInteractionEnabled:YES];
        [carousel setDelaysContentTouches:YES];
        [carousel setExclusiveTouch:YES];
        [carousel setCanCancelContentTouches:YES];
        [carousel setBackgroundColor:FT_GRAY];
        [carousel setPagingEnabled: YES];
        [carousel setAlwaysBounceVertical:NO];
        
        [self.galleryButton addSubview:carousel];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 320, 320);
    self.galleryButton.frame = CGRectMake(0, 0, 320, 320);
}

#pragma mark - FTGalleryCellView

- (void)setGallery:(PFObject *)aGallery {
    gallery = aGallery;
    
    [self.swiperView setAlpha:0];
    
    // Clear the carousel
    for (UIView *carouseSubView in carousel.subviews) {
        [carouseSubView removeFromSuperview];
    }
    
    /* Fetch all images and add them to the scrollview */
    [PFObject fetchAllIfNeededInBackground:[gallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            int i = 0;
            for (PFObject *post in objects) {
                PFFile *file = [post objectForKey:kFTPostImageKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                        singleTap.numberOfTapsRequired = 1;
                        
                        CGFloat xOrigin = i * self.frame.size.width;
                        
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, 320)];
                        [imageView setBackgroundColor:[UIColor clearColor]];
                        
                        UIImage *image = [UIImage imageWithData:data];
                        [imageView setImage:image];
                        [imageView setClipsToBounds:YES];
                        [imageView setContentMode:CONTENTMODE];
                        [imageView setUserInteractionEnabled:YES];
                        [imageView addGestureRecognizer:singleTap];
                        
                        [carousel addSubview:imageView];
                    }
                }];
                i++;
            }
            
            if (objects.count > 1) {
                [self.swiperView setNumberOfDashes:i];
                [self.contentView addSubview:self.swiperView];
                [self.swiperView setAlpha:1];
            }
            [carousel setContentSize: CGSizeMake(self.frame.size.width * objects.count, 320)];
       } 
    }];
     
    // User profile image
    PFUser *user = [self.gallery objectForKey:kFTPostUserKey];
    //PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    //[self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    //CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & FTGalleryCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsComment){
        //constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsLike){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikeGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsMore){
        //constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    /* Location */
    PFGeoPoint *geoPoint = [self.gallery objectForKey:kFTPostLocationKey];
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
                        
                        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                        action:@selector(didTapLocationAction:)];
                        tapRecognizer.numberOfTapsRequired = 1;
                        [locationLabel addGestureRecognizer:tapRecognizer];
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
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikeGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikeGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)killScroll {
    self.carousel.scrollEnabled = NO;
    self.carousel.scrollEnabled = YES;
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

+ (void)validateButtons:(FTGalleryCellButtons)buttons {
    if (buttons == FTGalleryCellButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTGalleryHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender{
    NSLog(@"FTGalleryCell::didTapUserButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapUserButton:user:)]) {
        [delegate galleryCellView:self didTapUserButton:sender user:[self.gallery objectForKey:kFTPostUserKey]];
    }
}

- (void)didTapLikeGalleryButtonAction:(UIButton *)button {
    NSLog(@"FTGalleryCell::didTapLikeGalleryButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapLikeGalleryButton:counter:gallery:)]) {
        [delegate galleryCellView:self didTapLikeGalleryButton:button counter:self.likeCounter gallery:self.gallery];
    }
}

- (void)didTapCommentOnGalleryButtonAction:(UIButton *)sender {
    NSLog(@"FTGalleryCell::didTapCommentOnGalleryButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapCommentOnGalleryButton:gallery:)]) {
        [delegate galleryCellView:self didTapCommentOnGalleryButton:sender gallery:self.gallery];
    }
}

-(void)didTapImageInGalleryAction:(UIButton *)sender {
    NSLog(@"FTGalleryCell::didTapImageInGalleryAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapImageInGalleryAction:gallery:)]) {
        [delegate galleryCellView:self didTapImageInGalleryAction:sender gallery:self.gallery];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender {
    NSLog(@"FTGalleryCell::didTapMoreButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapMoreButton:gallery:)]){
        [delegate galleryCellView:self didTapMoreButton:sender gallery:self.gallery];
    }
}

- (void)didTapLocationAction:(UIButton *)sender {
    NSLog(@"FTGalleryCell::didTapLocationAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapLocation:gallery:)]){
        [delegate galleryCellView:self didTapLocation:sender gallery:self.gallery];
    }
}

@end

