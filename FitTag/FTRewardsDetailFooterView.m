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
@end

@implementation FTRewardsDetailFooterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"FTRewardsDetailFooterView");
        self.contentView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.contentView];
        
        [self.contentView setBackgroundColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1]];
        
        UIButton *redeemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat redeemButtonW = 182.0f;
        CGFloat redeemButtonH = 40.0f;
        CGFloat paddingX = (self.frame.size.width - redeemButtonW) / 2; // Button width:182
        CGFloat paddingY = (self.frame.size.height - redeemButtonH) / 2;
        
        [redeemButton setFrame:CGRectMake(paddingX, paddingY, redeemButtonW, redeemButtonH)];
        [redeemButton setBackgroundImage:[UIImage imageNamed:@"redeem_reward"] forState:UIControlStateNormal];
        [redeemButton addTarget:self action:@selector(didTapRedeemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:redeemButton];
    }
    return self;
}

- (void)didTapRedeemButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rewardsDetailFooterView:didTapRedeemButton:)]){
        [self.delegate rewardsDetailFooterView:self didTapRedeemButton:sender];
    }
}

@end
