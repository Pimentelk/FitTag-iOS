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
        
        self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = CONTENTMODE;
        
        self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.galleryButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        self.galleryButton.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.galleryButton];
        
        CGSize frameSize = self.frame.size;
        
        UIView *toolbar = [[UIView alloc] init];
        toolbar.frame = CGRectMake(0, self.galleryButton.frame.size.height, frameSize.width, 30);
        toolbar.backgroundColor = FT_GRAY;
        
        [self.contentView addSubview:toolbar];
        
        FTGalleryCellButtons otherButtons = FTGalleryCellButtonsDefault;
        [FTGalleryCell validateButtons:otherButtons];
        buttons = otherButtons;
        
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
        
        [toolbar addSubview:moreButton];
        
        if (self.buttons & FTGalleryCellButtonsComment) {
            
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
            [self.commentButton setBackgroundImage:COMMENT_BUBBLE forState:UIControlStateNormal];
            [self.commentButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.commentButton setSelected:NO];
            
            [toolbar addSubview:self.commentButton];
        }
        
        if (self.buttons & FTGalleryCellButtonsLike) {
            
            CGFloat likeCounterX = commentButton.frame.origin.x - COUNTER_WIDTH - BUTTON_PADDING;
            
            // like counter
            likeCounter = [UIButton buttonWithType:UIButtonTypeCustom];
            [likeCounter setFrame:CGRectMake(likeCounterX, BUTTONS_TOP_PADDING, COUNTER_WIDTH, COUNTER_HEIGHT)];
            [likeCounter setBackgroundColor:[UIColor clearColor]];
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
        }
        
        swiperView = [[FTGallerySwiperView alloc] init];
        
        carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.width)];
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
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
    self.galleryButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
}

#pragma mark - FTGalleryCellView

- (void)setGallery:(PFObject *)aGallery {
    gallery = aGallery;
    
    [self.swiperView setAlpha:0];
    [carousel setAlpha:0];
    
    // Clear the carousel
    for (UIView *carouseSubView in carousel.subviews) {
        [carouseSubView removeFromSuperview];
    }
    
    /* Fetch all images and add them to the scrollview */
    [PFObject fetchAllIfNeededInBackground:[gallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            int i = 0;
            
            CGSize gallerySize = self.galleryButton.frame.size;
            [swiperView setFrame:CGRectMake(0, 0, (16 * objects.count), 20)];
            [swiperView setCenter:CGPointMake(gallerySize.width/2, gallerySize.height-5)];
            
            for (PFObject *post in objects) {
                [[post objectForKey:kFTPostImageKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                        singleTap.numberOfTapsRequired = 1;
                        
                        CGFloat xOrigin = i * self.frame.size.width;
                        
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, self.frame.size.width)];
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
                
                //[[FTCache sharedCache] setAttributesForPost:post likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                //[[FTCache sharedCache] setImagesForGallery:gallery];
                i++;
            }
            
            if (objects.count > 1) {
                [self.swiperView setNumberOfDashes:i];
                [self.contentView addSubview:self.swiperView];
                [self.swiperView setAlpha:1];
            }
            
            [carousel setContentSize: CGSizeMake(self.frame.size.width * objects.count, self.frame.size.width)];
       }
    }];
    
    // User profile image
    PFUser *user = [self.gallery objectForKey:kFTPostUserKey];
    
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    if (self.buttons & FTGalleryCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsComment){
        [self.commentButton addTarget:self action:@selector(didTapCommentOnGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsLike){
        [self.likeButton addTarget:self action:@selector(didTapLikeGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];        
        [self.likeCounter addTarget:self action:@selector(didTapLikeCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsMore){
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
    
    [self performSelector:@selector(showCarousel) withObject:nil afterDelay:1];
    [self setNeedsDisplay];
}

- (void)showCarousel {
    [UIView animateWithDuration:0.2 animations:^{
        [carousel setAlpha:1];
    }];
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
    //NSLog(@"FTGalleryCell::didTapUserButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapUserButton:user:)]) {
        [delegate galleryCellView:self didTapUserButton:sender user:[self.gallery objectForKey:kFTPostUserKey]];
    }
}

- (void)didTapLikeGalleryButtonAction:(UIButton *)button {
    //NSLog(@"FTGalleryCell::didTapLikeGalleryButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapLikeGalleryButton:counter:gallery:)]) {
        [delegate galleryCellView:self didTapLikeGalleryButton:button counter:self.likeCounter gallery:self.gallery];
    }
}

- (void)didTapCommentOnGalleryButtonAction:(UIButton *)sender {
    //NSLog(@"FTGalleryCell::didTapCommentOnGalleryButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapCommentOnGalleryButton:gallery:)]) {
        [delegate galleryCellView:self didTapCommentOnGalleryButton:sender gallery:self.gallery];
    }
}

-(void)didTapImageInGalleryAction:(UIButton *)sender {
    //NSLog(@"FTGalleryCell::didTapImageInGalleryAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapImageInGalleryAction:gallery:)]) {
        [delegate galleryCellView:self didTapImageInGalleryAction:sender gallery:self.gallery];
    }
}

- (void)didTapMoreButtonAction:(UIButton *)sender {
    //NSLog(@"FTGalleryCell::didTapMoreButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapMoreButton:gallery:)]){
        [delegate galleryCellView:self didTapMoreButton:sender gallery:self.gallery];
    }
}

- (void)didTapLocationAction:(UIButton *)sender {
    //NSLog(@"FTGalleryCell::didTapLocationAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapLocation:gallery:)]){
        [delegate galleryCellView:self didTapLocation:sender gallery:self.gallery];
    }
}

- (void)didTapLikeCountButtonAction:(UIButton *)button {
    //NSLog(@"FTGalleryCell::didTapLikeCountButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(galleryCellView:didTapLikeCountButton:gallery:)]){
        [delegate galleryCellView:self didTapLikeCountButton:button gallery:gallery];
    }
}

@end

