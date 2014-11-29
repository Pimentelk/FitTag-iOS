//
//  FTPostHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostHeaderView.h"
#import "FTProfileImageView.h"

@interface FTPostHeaderView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FTProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@end

@implementation FTPostHeaderView
@synthesize delegate;
@synthesize post;
@synthesize userButton;
@synthesize containerView;
@synthesize avatarImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {                
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];

        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.bounds.size.height)];
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
        [[self.userButton titleLabel] setFont:BENDERSOLID(18)];
        [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.userButton titleLabel] setShadowOffset:CGSizeMake(0,1)];
        [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.750f] forState:UIControlStateNormal];
        
        [containerView addSubview:self.userButton];
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
    CGFloat userButtonPointHeight = (self.frame.size.height - 10) / 2;
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

#pragma mark - ()

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(postHeaderView:didTapUserButton:user:)]) {
        [delegate postHeaderView:self didTapUserButton:sender user:[self.post objectForKey:kFTPostUserKey]];
    }
}

@end
