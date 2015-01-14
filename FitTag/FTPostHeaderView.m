//
//  FTPostHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostHeaderView.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"

#define TIMELABEL_WIDTH 100

@interface FTPostHeaderView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeFormatter;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation FTPostHeaderView
@synthesize delegate;
@synthesize post;
@synthesize userButton;
@synthesize containerView;
@synthesize avatarImageView;
@synthesize timeFormatter;
@synthesize timeLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat containerHeight = self.bounds.size.height;
        CGSize frameSize = self.frame.size;
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,frameSize.width,containerHeight)];
        [self.containerView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.containerView];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:containerView.frame];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [backgroundView setAlpha:1];
        [self.containerView addSubview:backgroundView];
        
        self.avatarImageView = [[FTProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake(AVATAR_X,AVATAR_Y,AVATAR_WIDTH,AVATAR_HEIGHT);
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.containerView addSubview:self.avatarImageView];
        
        // This is the user's display name, on a button so that we can tap on it
        self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.userButton setBackgroundColor:[UIColor clearColor]];
        [[self.userButton titleLabel] setFont:MULIREGULAR(18)];
        [self.userButton setTitleColor:FT_RED forState:UIControlStateNormal];
        [self.userButton setTitleColor:FT_DARKGRAY forState:UIControlStateHighlighted];
        [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.userButton titleLabel] setShadowOffset:CGSizeMake(0,1)];
        [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.750f] forState:UIControlStateNormal];
        
        [containerView addSubview:self.userButton];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:MULIREGULAR(14)];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.timeLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.70f]];
        [self.timeLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.timeLabel setText:EMPTY_STRING];
        
        [containerView addSubview:self.timeLabel];
    }
    
    return self;
}

- (void)setPost:(PFObject *)aPost {
    
    post = aPost;
    
    //NSLog(@"post:%@",[self.post objectForKey:kFTPostUserKey]);
    
    // user's avatar
    PFUser *user = [self.post objectForKey:kFTPostUserKey];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
            [self.avatarImageView setFile:profilePictureSmall];
            
            NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
            [self.userButton setTitle:authorName forState:UIControlStateNormal];
        }
    }];
    
    if ([user isDataAvailable]) {
        PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
        [self.avatarImageView setFile:profilePictureSmall];
        
        NSString *authorName = [user objectForKey:kFTUserDisplayNameKey];
        [self.userButton setTitle:authorName forState:UIControlStateNormal];
    }
    
    [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGFloat constrainWidth = containerView.bounds.size.width;
    CGFloat userButtonPointWidth = self.avatarImageView.frame.size.width + self.avatarImageView.frame.origin.x + 10;
    CGFloat userButtonPointHeight = (self.frame.size.height - 18) / 2;
    CGPoint userButtonPoint = CGPointMake(userButtonPointWidth,userButtonPointHeight);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    
    CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                          context:nil].size;
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    [self setNeedsDisplay];
}

- (void)setDate:(NSDate *)date {
    if (date) {
        
        NSString *time = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
        NSDictionary *userAttributes = @{NSFontAttributeName: MULIREGULAR(14)};
        CGSize stringBoundingBox = [time sizeWithAttributes:userAttributes];
        
        CGFloat frameWidth = self.frame.size.width;
        CGFloat padding = 15;
        
        [self.timeLabel setFrame:CGRectMake(frameWidth-stringBoundingBox.width-padding, 0, stringBoundingBox.width, self.bounds.size.height)];
        
        [self.timeLabel setText:time];
        [self setNeedsDisplay];
    }
}

#pragma mark - ()

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(postHeaderView:didTapUserButton:user:)]) {
        [delegate postHeaderView:self didTapUserButton:sender user:[self.post objectForKey:kFTPostUserKey]];
    }
}

@end
