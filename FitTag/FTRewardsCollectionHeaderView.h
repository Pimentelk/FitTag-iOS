//
//  UIView+FTRewardsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTRewardsCollectionHeaderViewDelegate;

@interface FTRewardsCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *activeTab;
@property (nonatomic, strong) UILabel *usedTab;
@property (nonatomic, strong) UILabel *expiredTab;

/*! @name Delegate */
@property (nonatomic,weak) id <FTRewardsCollectionHeaderViewDelegate> delegate;

/*!
 Initializes the view with the specified frame
 */
- (id)initWithFrame:(CGRect)frame;
//- (void)setReward:(NSInteger)cap;
@end

@protocol FTRewardsCollectionHeaderViewDelegate <NSObject>
@optional

- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapActiveTab:(id)tab;
- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapUsedTab:(id)tab;
- (void)rewardsHeaderView:(FTRewardsCollectionHeaderView *)rewardsHeaderView didTapExpiredTab:(id)tab;

@end