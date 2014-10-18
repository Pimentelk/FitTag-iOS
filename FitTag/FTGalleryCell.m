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

@property (nonatomic, strong) FTProfileImageView *avatarImageView;

@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, strong) FTGallerySwiperView *swiperView;
@end

@implementation FTGalleryCell
@synthesize galleryButton;
@synthesize containerView;
@synthesize avatarImageView;
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
@synthesize usernameRibbon;
@synthesize carousel;
@synthesize swiperView;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.galleryButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.galleryButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.galleryButton];
        
        UIView *galleryCellButtonsContainer = [[UIView alloc] init];
        galleryCellButtonsContainer.frame = CGRectMake(120.0f, 295.0f, 200.0f, 22.0f);
        galleryCellButtonsContainer.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:galleryCellButtonsContainer];
        
        FTGalleryCellButtons otherButtons = FTGalleryCellButtonsDefault;
        [FTGalleryCell validateButtons:otherButtons];
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
        UIImage *image = [FTGalleryCell imageWithImage:[UIImage imageNamed:@"username_ribbon"] scaledToSize:CGSizeMake(88.0f, 20.0f)];
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
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, 110, 40)];
        [locationLabel setText:@""];
        [locationLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:locationLabel];
        [self bringSubviewToFront:locationLabel];
        
        if (self.buttons & FTGalleryCellButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [galleryCellButtonsContainer addSubview:self.likeButton];
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
            [galleryCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTGalleryCellButtonsComment) {
            
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [galleryCellButtonsContainer addSubview:self.commentButton];
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
            [galleryCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(commentCounter.frame.size.width + commentCounter.frame.origin.x + 15.0f, commentCounter.frame.origin.y, 35.0f, 19.0f)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:@"" forState:UIControlStateNormal];
        [galleryCellButtonsContainer addSubview:moreButton];
        
        swiperView = [[FTGallerySwiperView alloc] initWithFrame:CGRectMake(usernameRibbon.frame.origin.x + EXTRA_PADDING,
                                                                           usernameRibbon.frame.origin.y + usernameRibbon.frame.size.height,
                                                                           usernameRibbon.frame.size.width - REMOVE_EXTRA_PADDING,
                                                                           usernameRibbon.frame.size.height)];
        
        carousel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320.0f,320.0f)];
        [carousel setDelegate:self];
        [carousel setUserInteractionEnabled:YES];
        [carousel setDelaysContentTouches:YES];
        [carousel setExclusiveTouch:YES];
        [carousel setCanCancelContentTouches:YES];
        [carousel setBackgroundColor:[UIColor clearColor]];
        [carousel setPagingEnabled: YES];
        [carousel setAlwaysBounceVertical:NO];
        [carousel setHidden:YES];
        [self.galleryButton addSubview:carousel];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
    self.galleryButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
}

#pragma mark - FTGalleryCellView

- (void)setGallery:(PFObject *)aGallery {
    gallery = aGallery;
    
    /* Fetch all images and add them to the scrollview */
    [PFObject fetchAllIfNeededInBackground:[gallery objectForKey:kFTPostPostsKey] block:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // Clear the carousel
            for (UIView *carouseSubView in carousel.subviews) {
                [carouseSubView removeFromSuperview];
            }
            
            int i = 0;
            for (PFObject *post in objects) {
                PFFile *file = [post objectForKey:kFTPostImageKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                        singleTap.numberOfTapsRequired = 1;
                        
                        CGFloat xOrigin = i * 320;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 320.0f, 320.0f)];
                        [imageView setBackgroundColor:[UIColor clearColor]];
                        UIImage *image = [UIImage imageWithData:data];
                        [imageView setImage:image];
                        [imageView setClipsToBounds:YES];
                        [imageView setContentMode:UIViewContentModeScaleAspectFill];
                        [imageView setUserInteractionEnabled:YES];
                        [imageView addGestureRecognizer:singleTap];
                        [carousel addSubview:imageView];
                    }
                }];
                i++;
            }
            
            [self.swiperView setNumberOfDashes:i];
            [self.contentView addSubview:self.swiperView];
            
            [carousel setContentSize: CGSizeMake(320.0f * objects.count, 320.0f)];
            [carousel setHidden:NO];
       } 
    }];
     
    // User profile image
    PFUser *user = [self.gallery objectForKey:kFTPostUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    [self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & FTGalleryCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsComment){
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsLike){
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikeGalleryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTGalleryCellButtonsMore){
        constrainWidth = self.likeButton.frame.origin.x;
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
        [locationLabel setText:@""];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
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

- (void)killScroll {
    self.carousel.scrollEnabled = NO;
    self.carousel.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //NSLog(@"FTGalleryCell::scrollViewDidScroll");
    /*
    ScrollDirection scrollDirection;
    if (self.lastContentOffset > scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionRight;
        [self.swiperView onGallerySwipedRight];
    } else if (self.lastContentOffset < scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionLeft;
        [self.swiperView onGallerySwipedLeft];        
    }
    
    self.lastContentOffset = scrollView.contentOffset.x;
    */
}

#pragma mark - ()

- (UIImageView *)getProfileHexagon {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake( 4.0f, 4.0f, 42.0f, 42.0f);
    imageView.backgroundColor = [UIColor clearColor];
    
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

