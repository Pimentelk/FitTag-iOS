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

/*! @name Delegate */
@property (nonatomic,weak) id <FTBusinessProfileHeaderViewDelegate> delegate;
- (void)fetchBusinessProfileData:(PFUser *)aBusiness;
@end

@protocol FTBusinessProfileHeaderViewDelegate <NSObject>
@optional

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapGetThereButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapCallButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapVideoButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapEmailButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapFollowButton:(UIButton *)button;

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapGridButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapBusinessButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapTaggedButton:(UIButton *)button;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapSettingsButton:(id)sender;

- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapFollowersButton:(id)sender;
- (void)businessProfileCollectionHeaderView:(FTBusinessProfileHeaderView *)businessProfileCollectionHeaderView didTapFollowingButton:(id)sender;
@end