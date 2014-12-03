//
//  UIToolbar+rgarg.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//
@protocol FTBusinessProfileHeaderViewDelegate;

@interface FTBusinessProfileHeaderView : UICollectionReusableView

/*! @name User */
@property (nonatomic, strong) PFUser *business;

/*! @name isFollowing */
@property (nonatomic) BOOL isFollowing;

- (void)configureFollowButtons;

/*! @name Delegate */
@property (nonatomic,weak) id <FTBusinessProfileHeaderViewDelegate> delegate;
- (void)fetchBusinessProfileData:(PFUser *)aBusiness;
@end

@protocol FTBusinessProfileHeaderViewDelegate <NSObject>
@optional

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapGetThereButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapCallButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapVideoButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapEmailButton:(UIButton *)button;
//- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapFollowButton:(UIButton *)button;
//- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapUnfollowButton:(UIButton *)button;

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapGridButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapBusinessButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapTaggedButton:(UIButton *)button;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapSettingsButton:(id)sender;

- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapFollowersButton:(id)sender;
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapFollowingButton:(id)sender;
@end