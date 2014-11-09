//
//  UITableView+FTProfileCollectionHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTUserProfileHeaderViewDelegate;

@interface FTUserProfileHeaderView : UICollectionReusableView

/*! @name User */
@property (nonatomic,strong) PFUser *user;

/*! @name Delegate */
@property (nonatomic,weak) id <FTUserProfileHeaderViewDelegate> delegate;
- (void)fetchUserProfileData:(PFUser *)aUser;
@end

@protocol FTUserProfileHeaderViewDelegate <NSObject>
@optional

- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapGridButton:(UIButton *)button;
- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapBusinessButton:(UIButton *)button;
- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapTaggedButton:(UIButton *)button;
- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapSettingsButton:(id)sender;
- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapFollowersButton:(id)sender;
- (void)userProfileCollectionHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapFollowingButton:(id)sender;
@end