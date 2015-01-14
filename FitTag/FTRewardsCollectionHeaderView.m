//
//  FTRewardsHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsCollectionHeaderView.h"

#define TAPS_REQUIRED 1

@interface FTRewardsCollectionHeaderView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIProgressView *progressView;
@property NSInteger rewardCap;
@property UILabel *rewardsLabel;
@property UIColor *selectedColor;
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
        
        self.selectedColor = FT_RED;
        
        containerView = [[UIView alloc] initWithFrame:frame];
        [containerView setBackgroundColor:FT_GRAY];
        [self addSubview:containerView];
        
        /*
         
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
        */
        
        // Rewards menu
        UIView *menuContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, REWARDS_MENU_HEIGHT)];
        [menuContainer setBackgroundColor:[UIColor clearColor]];
        
        UIView *lineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 2)];
        lineViewWhite.backgroundColor = [UIColor whiteColor];
        [menuContainer addSubview:lineViewWhite];
        
        /*
        UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 8.0f, self.frame.size.width, 22.0)];
        menuLabel.textAlignment =  NSTextAlignmentLeft;
        menuLabel.textColor = [UIColor redColor];
        menuLabel.font = BENDERSOLID(18.0);
        menuLabel.text = @"My Rewards";
        [menuContainer addSubview:menuLabel];
        */
        
        //CGFloat menuPaddingTop = menuLabel.frame.origin.y + menuLabel.frame.size.height + 6.0f;
        
        //CGFloat menuPaddingTop = MENU_CONTAINER_PADDING;
        
        CGFloat menuTabWidth = self.frame.size.width / 3;
        
        UITapGestureRecognizer *activeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapActiveTabAction:)];
        [activeTapGesture setNumberOfTapsRequired:TAPS_REQUIRED];
        self.activeTab = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, ceilf(menuTabWidth), self.frame.size.height)];
        [self.activeTab setText:@"Active"];
        [self.activeTab setTextAlignment:NSTextAlignmentCenter];
        [self.activeTab setTextColor:[UIColor whiteColor]];
        [self.activeTab setBackgroundColor:self.selectedColor];
        [self.activeTab setFont:MULIREGULAR(16)];
        [self.activeTab setUserInteractionEnabled:YES];
        [self.activeTab addGestureRecognizer:activeTapGesture];
        [menuContainer addSubview:self.activeTab];
        
        UITapGestureRecognizer *usedTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUsedTabAction:)];
        [usedTapGesture setNumberOfTapsRequired:TAPS_REQUIRED];
        self.usedTab = [[UILabel alloc] initWithFrame:CGRectMake( ceilf(menuTabWidth), 0, ceilf(menuTabWidth), self.frame.size.height)];
        [self.usedTab setText:@"Used"];
        [self.usedTab setTextAlignment:NSTextAlignmentCenter];
        [self.usedTab setTextColor:[UIColor blackColor]];
        [self.usedTab setBackgroundColor:[UIColor lightGrayColor]];
        [self.usedTab setFont:MULIREGULAR(16)];
        [self.usedTab setUserInteractionEnabled:YES];
        [self.usedTab addGestureRecognizer:usedTapGesture];
        [menuContainer addSubview:self.usedTab];
        
        UITapGestureRecognizer *expiredTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapExpiredTabAction:)];
        [expiredTapGesture setNumberOfTapsRequired:TAPS_REQUIRED];
        self.expiredTab = [[UILabel alloc] initWithFrame:CGRectMake( ceilf(menuTabWidth*2), 0, ceilf(menuTabWidth), self.frame.size.height)];
        [self.expiredTab setText:@"Expired"];
        [self.expiredTab setTextAlignment:NSTextAlignmentCenter];
        [self.expiredTab setTextColor:[UIColor blackColor]];
        [self.expiredTab setBackgroundColor:[UIColor lightGrayColor]];
        [self.expiredTab setFont:MULIREGULAR(16)];
        [self.expiredTab setUserInteractionEnabled:YES];
        [self.expiredTab addGestureRecognizer:expiredTapGesture];
        [menuContainer addSubview:self.expiredTab];
        
        /*
        self.activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activeButton setFrame: CGRectMake( 0, 0, menuButtonWidth, self.frame.size.height)];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active"] forState:UIControlStateNormal];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active_selected"] forState:UIControlStateSelected];
        [self.activeButton setBackgroundImage:[UIImage imageNamed:@"active_selected"] forState:UIControlStateHighlighted];
        [self.activeButton addTarget:self action:@selector(didTapActiveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.activeButton setSelected:YES];
        
        self.usedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.usedButton setFrame: CGRectMake( menuButtonWidth, 0, menuButtonWidth, self.frame.size.height)];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used"] forState:UIControlStateNormal];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used_selected"] forState:UIControlStateSelected];
        [self.usedButton setBackgroundImage:[UIImage imageNamed:@"used_selected"] forState:UIControlStateHighlighted];
        [self.usedButton addTarget:self action:@selector(didTapUsedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [menuContainer addSubview:self.usedButton];
        
        self.expiredButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.expiredButton setFrame: CGRectMake( menuButtonWidth*2, 0, menuButtonWidth, self.frame.size.height)];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired"] forState:UIControlStateNormal];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired_selected"] forState:UIControlStateSelected];
        [self.expiredButton setBackgroundImage:[UIImage imageNamed:@"expired_selected"] forState:UIControlStateHighlighted];
        [self.expiredButton addTarget:self action:@selector(didTapExpiredButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [menuContainer addSubview:self.expiredButton];
         */
        [self addSubview:menuContainer];
    }
    return self;
}

/*
- (void)setReward:(NSInteger)cap {
    rewardCap = cap;
}
*/

- (void)clearSelectedTabsAction {
    [self.activeTab setBackgroundColor:[UIColor lightGrayColor]];
    [self.usedTab setBackgroundColor:[UIColor lightGrayColor]];
    [self.expiredTab setBackgroundColor:[UIColor lightGrayColor]];
    [self.activeTab setTextColor:[UIColor blackColor]];
    [self.usedTab setTextColor:[UIColor blackColor]];
    [self.expiredTab setTextColor:[UIColor blackColor]];
}

- (void)didTapActiveTabAction:(id)tab {
    
    [self clearSelectedTabsAction];
    [self.activeTab setBackgroundColor:self.selectedColor];
    [self.activeTab setTextColor:[UIColor whiteColor]];
    
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapActiveTab:)]){
        [delegate rewardsHeaderView:self didTapActiveTab:tab];
    }
}

- (void)didTapUsedTabAction:(id)tab {
    
    [self clearSelectedTabsAction];
    [self.usedTab setBackgroundColor:self.selectedColor];
    [self.usedTab setTextColor:[UIColor whiteColor]];
    
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapUsedTab:)]){
        [delegate rewardsHeaderView:self didTapUsedTab:tab];
    }
}

- (void)didTapExpiredTabAction:(id)tab {
    
    [self clearSelectedTabsAction];
    [self.expiredTab setBackgroundColor:self.selectedColor];
    [self.expiredTab setTextColor:[UIColor whiteColor]];
    
    if(delegate && [delegate respondsToSelector:@selector(rewardsHeaderView:didTapExpiredTab:)]){
        [delegate rewardsHeaderView:self didTapExpiredTab:tab];
    }
}

@end
