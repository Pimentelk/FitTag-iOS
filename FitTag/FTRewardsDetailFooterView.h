//
//  UIView+FTRewardsDetailFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTRewardsDetailsFooterViewDelegate;
@interface FTRewardsDetailFooterView : UIView

@property (nonatomic,weak) id <FTRewardsDetailsFooterViewDelegate> delegate;
@property (nonatomic, strong) UIButton *redeemButton;
@property BOOL canRedeem;

- (id)initWithFrame:(CGRect)frame reward:(PFObject *)reward;

@end

@protocol FTRewardsDetailsFooterViewDelegate <NSObject>
@optional

- (void)rewardsDetailFooterView:(FTRewardsDetailFooterView *)footerView didTapRedeemButton:(UIButton *)button;

@end