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
@property BOOL canRedeem;
@end

@protocol FTRewardsDetailsFooterViewDelegate <NSObject>
@optional

- (void)rewardsDetailFooterView:(FTRewardsDetailFooterView *)footerView didTapRedeemButton:(UIButton *)button;

@end