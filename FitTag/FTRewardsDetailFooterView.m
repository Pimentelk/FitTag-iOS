//
//  UIView+FTRewardsDetailFooterView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailFooterView.h"

@interface FTRewardsDetailFooterView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *redeemButton;
@end

@implementation FTRewardsDetailFooterView
@synthesize redeemButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"FTRewardsDetailFooterView");
        self.contentView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.contentView];
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat redeemButtonW = 182.0f;
        CGFloat redeemButtonH = 40.0f;
        CGFloat paddingX = (self.frame.size.width - redeemButtonW) / 2; // Button width:182
        CGFloat paddingY = (self.frame.size.height - redeemButtonH) / 2;
        
        [redeemButton setFrame:CGRectMake(paddingX, paddingY, redeemButtonW, redeemButtonH)];
        [redeemButton setBackgroundImage:[UIImage imageNamed:@"redeem_reward"] forState:UIControlStateNormal];
        [redeemButton addTarget:self action:@selector(didTapRedeemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self showRedeemButton];
    }
    return self;
}

- (void)showRedeemButton {
    
    self.canRedeem = NO;
    
    PFQuery *queryReward = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryReward whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryReward whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeRedeem];
    [queryReward whereKeyExists:kFTActivityRewardKey];
    [queryReward countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == 0) {
                [self.contentView addSubview:redeemButton];
                self.canRedeem = YES;
            }
        }
    }];
}

- (void)didTapRedeemButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rewardsDetailFooterView:didTapRedeemButton:)]){
        [self.delegate rewardsDetailFooterView:self didTapRedeemButton:sender];
    }
}

@end
