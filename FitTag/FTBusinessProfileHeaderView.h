//
//  UIToolbar+rgarg.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "STTweetLabel.h"

@protocol FTBusinessProfileHeaderViewDelegate;

@interface FTBusinessProfileHeaderView : UICollectionReusableView

/*! @name User */
@property (nonatomic, strong) PFUser *business;

/*! @name isFollowing */
@property (nonatomic) BOOL isFollowing;

/*! @name Delegate */
@property (nonatomic,weak) id <FTBusinessProfileHeaderViewDelegate> delegate;

- (void)configureFollowButtons;

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

/*!
 Sent to the delegate when a hashtag is tapped
 @param Hashtag the Hashtag that was tapped
 */
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapHashtag:(NSString *)Hashtag;

/*!
 Sent to the delegate when a user button is tapped
 @param link the link that was tapped
 */
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapLink:(NSString *)link;

/*!
 Sent to the delegate when a user mention is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)businessProfileHeaderView:(FTBusinessProfileHeaderView *)businessProfileHeaderView didTapUserMention:(NSString *)mention;

@end