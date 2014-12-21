//
//  UITableView+FTProfileCollectionHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "STTweetLabel.h"

@protocol FTUserProfileHeaderViewDelegate;

@interface FTUserProfileHeaderView : UICollectionReusableView

/*! @name User */
@property (nonatomic,strong) PFUser *user;

/*! @name Delegate */
@property (nonatomic,weak) id <FTUserProfileHeaderViewDelegate> delegate;

- (void)fetchUserProfileData:(PFUser *)aUser;
- (void)updateFollowerCount;
- (void)updateFollowingCount;
- (void)updateCoverPhoto:(UIImage *)photo;
- (void)updateProfilePicture:(UIImage *)photo;
- (void)updateBiography:(NSString *)bio;

@end

@protocol FTUserProfileHeaderViewDelegate <NSObject>
@optional


/*!
 Sent to the delegate when a hashtag is tapped
 @param Hashtag the Hashtag that was tapped
 */
//- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapGridButton:(UIButton *)button;

/*!
 Sent to the delegate when a hashtag is tapped
 @param Hashtag the Hashtag that was tapped
 */
//- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapBusinessButton:(UIButton *)button;

/*!
 Sent to the delegate when a hashtag is tapped
 @param Hashtag the Hashtag that was tapped
 */
//- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapTaggedButton:(UIButton *)button;

/*!
 Sent to the delegate when a settings button is tapped
 @param sender the id that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapSettingsButton:(id)sender;

/*!
 Sent to the delegate when followers is tapped
 @param sender the id that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapFollowersButton:(id)sender;

/*!
 Sent to the delegate when following is tapped
 @param sender the id that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapFollowingButton:(id)sender;

/*!
 Sent to the delegate when a hashtag is tapped
 @param Hashtag the Hashtag that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapHashtag:(NSString *)Hashtag;

/*!
 Sent to the delegate when a user button is tapped
 @param link the link that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapLink:(NSString *)link;

/*!
 Sent to the delegate when a user mention is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)userProfileHeaderView:(FTUserProfileHeaderView *)userProfileHeaderView didTapUserMention:(NSString *)mention;

@end