//
//  UIView+FTRewardsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTRewardsCollectionHeaderViewDelegate;

@interface FTRewardsCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UIButton *activeButton;
@property (nonatomic, strong) UIButton *usedButton;
@property (nonatomic, strong) UIButton *expiredButton;

/*! @name Delegate */
@property (nonatomic,weak) id <FTRewardsCollectionHeaderViewDelegate> delegate;

/*!
 Initializes the view with the specified frame
 */
- (id)initWithFrame:(CGRect)frame;
- (void)setReward:(NSInteger)cap;
- (void)clearSelectedButtons;
@end

@protocol FTRewardsCollectionHeaderViewDelegate <NSObject>
@optional

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapActiveButton:(UIButton *)button;
- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapUsedButton:(UIButton *)button;
- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapExpiredButton:(UIButton *)button;

@end