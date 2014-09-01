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
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end

@implementation FTPhotoCell
@synthesize photoButton;
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize commentCounter;
@synthesize likeCounter;
@synthesize moreButton;
@synthesize usernameRibbon;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
                
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        UIView *photoCellButtonsContainer = [[UIView alloc] init];
        photoCellButtonsContainer.frame = CGRectMake(120.0f, 295.0f, 200.0f, 22.0f);
        photoCellButtonsContainer.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:photoCellButtonsContainer];
        
        FTPhotoCellButtons otherButtons = FTPhotoCellButtonsDefault;
        [FTPhotoCell validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *profileHexagon = [self getProfileHexagon];
        
        self.avatarImageView = [[FTProfileImageView alloc] init];
        self.avatarImageView.frame = profileHexagon.frame;
        self.avatarImageView.layer.mask = profileHexagon.layer.mask;
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageView];
        
        //username_ribbon
        self.usernameRibbon = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [FTPhotoCell imageWithImage:[UIImage imageNamed:@"username_ribbon"] scaledToSize:CGSizeMake(88.0f, 20.0f)];
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
        
        if (self.buttons & FTPhotoCellButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [photoCellButtonsContainer addSubview:self.likeButton];
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
            [photoCellButtonsContainer addSubview:likeCounter];
        }
        
        if (self.buttons & FTPhotoCellButtonsComment) {
            
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [photoCellButtonsContainer addSubview:self.commentButton];
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
            [photoCellButtonsContainer addSubview:commentCounter];
        }
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"more_button"] forState:UIControlStateNormal];
        [moreButton setFrame:CGRectMake(commentCounter.frame.size.width + commentCounter.frame.origin.x + 15.0f, commentCounter.frame.origin.y, 35.0f, 19.0f)];
        [moreButton setBackgroundColor:[UIColor clearColor]];
        [moreButton setTitle:@"" forState:UIControlStateNormal];
        [photoCellButtonsContainer addSubview:moreButton];
        
        /*
        if (self.buttons & FTPhotoCellButtonsUser) {
            NSLog(@"FTPhotoCellButtonsUser");
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [photoCellButtonsContainer addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
            [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            [[self.userButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 210.0f, self.contentView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [self.contentView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.timestampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.timestampLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.timestampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        
        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        layer.masksToBounds = NO;
        layer.shadowRadius = 1.0f;
        layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        layer.shadowOpacity = 0.5f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.contentView.frame.size.height - 4.0f, self.contentView.frame.size.width, 4.0f)].CGPath;
        */
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
}

#pragma mark - FTPhotoCellView

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    
    // user's avatar
    PFUser *user = [self.photo objectForKey:kFTPhotoUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    [self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & FTPhotoCellButtonsUser){
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTPhotoCellButtonsComment){
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTPhotoCellButtonsLike){
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & FTPhotoCellButtonsMore){
        constrainWidth = self.likeButton.frame.origin.x;
        [self.moreButton addTarget:self action:@selector(didTapMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    /*
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    
    CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                          context:nil].size;
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];
    */
    
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
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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

+ (void)validateButtons:(FTPhotoCellButtons)buttons {
    if (buttons == FTPhotoCellButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender{
    if (delegate && [delegate respondsToSelector:@selector(photoCellView:didTapUserButton:user:)]) {
        [delegate photoCellView:self didTapUserButton:sender user:[self.photo objectForKey:kFTPhotoUserKey]];
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
@end

