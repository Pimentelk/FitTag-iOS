//
//  FTRewardsHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsCollectionHeaderView.h"

@interface FTRewardsCollectionHeaderView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIProgressView *progressView;
@property NSInteger rewardCap;
@property UILabel *rewardsLabel;
@end

@implementation FTRewardsCollectionHeaderView
@synthesize containerView;
@synthesize progressView;
@synthesize rewardCap;
@synthesize delegate;
@synthesize rewardsLabel;

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        
        containerView = [[UIView alloc] initWithFrame:frame];
        [containerView setBackgroundColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1]];
        
        PFUser *user = [PFUser currentUser];
        NSNumber *postCount = [user objectForKey:kFTUserPostCountKey];
        rewardCap = 10 - ([postCount integerValue] % 10);

        NSInteger postCountInt = [postCount integerValue];
        CGFloat progressPercent = (postCountInt % 10) * .1;
        
        [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"Fetching in background...");
                NSNumber *postCount = [object objectForKey:kFTUserPostCountKey];
                rewardCap = 10 - ([postCount integerValue] % 10);
                NSInteger postCountInt = [postCount integerValue];
                CGFloat progressPercent = (postCountInt % 10) * .1;
                [progressView setProgress: progressPercent];
                rewardsLabel.text = [NSString stringWithFormat: @"%ld POSTS TO MORE REWARDS",(long)rewardCap];
            }
        }];
        
        progressView = [[UIProgressView alloc] init];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 5.0f);
        progressView.transform = transform;
        
        UIView *progressViewBorder = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 15.0f, frame.size.width - 30.0f, 22.0f)];
        [progressViewBorder setBackgroundColor:[UIColor colorWithRed:154/255.0f green:154/255.0f blue:154/255.0f alpha:1]];        
        
        [progressView setFrame: CGRectMake(5.0f,10.0f,progressViewBorder.bounds.size.width - 10.0f,40.0f)];
        [progressView setProgressTintColor:[UIColor greenColor]];
        [progressView setUserInteractionEnabled:NO];
        [progressView setProgress: progressPercent];
        [progressView setProgressViewStyle:UIProgressViewStyleBar];
        [progressView setTrackTintColor:[UIColor whiteColor]];
        
        [progressViewBorder addSubview:progressView];
        [containerView addSubview:progressViewBorder];
        
        rewardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,50.0f, frame.size.width, 40.0)];
        rewardsLabel.textAlignment =  NSTextAlignmentCenter;
        rewardsLabel.textColor = [UIColor colorWithRed:154/255.0f green:154/255.0f blue:154/255.0f alpha:1];
        rewardsLabel.font = BENDERSOLID(18.0);
        rewardsLabel.text = [NSString stringWithFormat: @"%ld POSTS TO MORE REWARDS",(long)rewardCap];
        
        [containerView addSubview:rewardsLabel];
        
        [self addSubview:containerView];
        
        // Rewards menu
        UIView *menuContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 90.0f, self.frame.size.width, 70.0f)];
        [menuContainer setBackgroundColor:[UIColor clearColor]];
        
        UIView *lineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 2)];
        lineViewWhite.backgroundColor = [UIColor whiteColor];
        [menuContainer addSubview:lineViewWhite];
        
        UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f,8.0f, self.frame.size.width, 22.0)];
        menuLabel.textAlignment =  NSTextAlignmentLeft;
        menuLabel.textColor = [UIColor redColor];
        menuLabel.font = BENDERSOLID(18.0);
        menuLabel.text = @"My Rewards";
        [menuContainer addSubview:menuLabel];
        
        CGFloat menuPaddingTop = menuLabel.frame.origin.y + menuLabel.frame.size.height + 6.0f;
        
        self.activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activeButton setFrame: CGRectMake( 7.0f, menuPaddingTop, 97.0f, 28.0f)];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active"] forState:UIControlStateNormal];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active_selected"] forState:UIControlStateSelected];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active_selected"] forState:UIControlStateHighlighted];
        [self.activeButton addTarget:self action:@selector(didTapActiveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.activeButton setSelected:YES];
        [menuContainer addSubview:self.activeButton];
        
        self.usedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.usedButton setFrame: CGRectMake( 111.0f, menuPaddingTop, 97.0f, 28.0f)];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used"] forState:UIControlStateNormal];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used_selected"] forState:UIControlStateSelected];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used_selected"] forState:UIControlStateHighlighted];
        [self.usedButton addTarget:self action:@selector(didTapUsedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [menuContainer addSubview:self.usedButton];
        
        self.expiredButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.expiredButton setFrame: CGRectMake( 215.0f, menuPaddingTop, 97.0f, 28.0f)];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired"] forState:UIControlStateNormal];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired_selected"] forState:UIControlStateSelected];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired_selected"] forState:UIControlStateHighlighted];
        [self.expiredButton addTarget:self action:@selector(didTapExpiredButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [menuContainer addSubview:self.expiredButton];
        
        [self addSubview:menuContainer];
    }
    
    return self;
}

- (void)setReward:(NSInteger)cap {
    rewardCap = cap;
}

- (void)clearSelectedButtons {
    [self.activeButton setSelected:NO];
    [self.usedButton setSelected:NO];
    [self.expiredButton setSelected:NO];
}

- (void)didTapActiveButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapActiveButton:)]){
        [delegate rewardsHeaderView:self didTapActiveButton:button];
    }
}

- (void)didTapUsedButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapUsedButton:)]){
        [delegate rewardsHeaderView:self didTapUsedButton:button];
    }
}

- (void)didTapExpiredButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapExpiredButton:)]){
        [delegate rewardsHeaderView:self didTapExpiredButton:button];
    }
}

@end
