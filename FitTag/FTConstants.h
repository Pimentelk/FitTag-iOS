//
//  Constants.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
	FTActivityTabBarItemIndex = 0,
	FTSearchTabBarItemIndex = 1,
	FTFeedTabBarItemIndex = 2,
    FTProfileTabBarItemIndex = 3,
    FTReardsTabBarItemIndex = 4
} FTTabBarControllerViewControllerIndex;

#pragma mark - AppStoreURLFormat
extern NSString *const iOS7AppStoreURLFormat;
extern NSString *const iOSAppStoreURLFormat;

extern NSString *const googleMapsAPIPlaceAutocompleteURL;
extern NSString *const googleMapsAPIPlaceSearchURL;
extern NSString *const googleMapsAPIPlaceQueryURL;

#pragma mark - NSUserDefaults
extern NSString *const kFTUserDefaultsSettingsViewControllerPushLikesKey;
extern NSString *const kFTUserDefaultsSettingsViewControllerPushCommentsKey;
extern NSString *const kFTUserDefaultsSettingsViewControllerPushMentionsKey;
extern NSString *const kFTUserDefaultsSettingsViewControllerPushRewardsKey;
extern NSString *const kFTUserDefaultsSettingsViewControllerPushBusinessesKey;
extern NSString *const kFTUserDefaultsSettingsViewControllerPushFollowsKey;
extern NSString *const kFTUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kFTUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs
extern NSString *const kFTLaunchURLHostTakePicture;

#pragma mark - NSNotification

// Profile
extern NSString *const FTProfileDidChangeBioNotification;
extern NSString *const FTProfileDidChangeProfilePhotoNotification;
extern NSString *const FTProfileDidChangeCoverPhotoNotification;

// Comment box text
#define CAPTION_TEXT @"Write a caption"

// Remote
extern NSString *const FTAppDelegateApplicationDidReceiveRemoteNotification;

// Utilities
extern NSString *const FTUtilityUserFollowersChangedNotification;
extern NSString *const FTUtilityUserFollowingChangedNotification;
extern NSString *const FTUtilityBusinessFollowingChangedNotification;
extern NSString *const FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification;
extern NSString *const FTUtilityDidFinishProcessingProfilePictureNotification;

// Tabbar
extern NSString *const FTTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const FTTabBarControllerDidFinishImageFileUploadNotification;

// Timeline
extern NSString *const FTTimelineViewControllerUserDeletedPostNotification;

// Post
extern NSString *const FTPostDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const FTPostDetailsViewControllerUserCommentedOnPhotoNotification;

// Reward
extern NSString *const FTRewardsCollectionViewControllerUserReceiveRewardNotification;

#pragma mark - User Info Keys
extern NSString *const FTPostDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kFTEditPostViewControllerUserInfoCommentKey;

#pragma mark - Installation Class

// Field keys
extern NSString *const kFTInstallationUserKey;

#pragma mark - PFObject Activity Class

// Class key
extern NSString *const kFTActivityClassKey;

// Field keys
extern NSString *const kFTActivityTypeKey;
extern NSString *const kFTActivityFromUserKey;
extern NSString *const kFTActivityToUserKey;
extern NSString *const kFTActivityContentKey;
extern NSString *const kFTActivityPostKey;
extern NSString *const kFTActivityHashtagKey;
extern NSString *const kFTActivityMentionKey;
extern NSString *const kFTActivityWordKey;
extern NSString *const kFTActivityRewardKey;

// Type values
extern NSString *const kFTActivityTypeLike;
extern NSString *const kFTActivityTypeFollow;
extern NSString *const kFTActivityTypeComment;
extern NSString *const kFTActivityTypeJoined;
extern NSString *const kFTActivityTypeRedeem;
extern NSString *const kFTActivityTypeDelete;
extern NSString *const kFTActivityTypeBlock;
extern NSString *const kFTActivityTypeMention;
extern NSString *const kFTActivityTypeOffer;

#pragma mark - PFObject Post Class
extern NSString *const kFTPostClassKey;

// Field keys
extern NSString *const kFTPostKey;
extern NSString *const kFTPostUserKey;
extern NSString *const kFTPostThumbnailKey;
extern NSString *const kFTPostImageKey;
extern NSString *const kFTPostVideoKey;
extern NSString *const kFTPostTypeKey;
extern NSString *const kFTPostOpenGraphIDKey;
extern NSString *const kFTPostLocationKey;
extern NSString *const kFTPostPostsKey;
extern NSString *const kFTPostHashTagKey;
extern NSString *const kFTPostMentionKey;
extern NSString *const kFTPostCaptionKey;
extern NSString *const kFTPostPlaceKey;

extern NSString *const kFTPostTypeGallery;
extern NSString *const kFTPostTypeGalleryImage;
extern NSString *const kFTPostTypeGalleryVideo;
extern NSString *const kFTPostTypeImage;
extern NSString *const kFTPostTypeVideo;

#pragma mark - PFObject Interest Class
// Class key
extern NSString *const kFTInterestsClassKey;

// Field keys
extern NSString *const kFTInterestKey;

#pragma mark - PFObject Rewards Class

// Class key
extern NSString *const kFTRewardClassKey;

// Field keys
extern NSString *const kFTRewardNameKey;
extern NSString *const kFTRewardDescriptionKey;
extern NSString *const kFTRewardTypeKey;
extern NSString *const kFTRewardUserKey;
extern NSString *const kFTRewardExpiredKey;
extern NSString *const kFTRewardImageKey;
extern NSString *const kFTRewardStatusKey;

// Type values
extern NSString *const kFTRewardTypeActive;
extern NSString *const kFTRewardTypeInactive;
extern NSString *const kFTRewardTypeUsed;
extern NSString *const kFTRewardTypeExpired;

#pragma mark - PFObject User Class

// Class key
extern NSString *const kFTUserClassKey;

// Field keys
extern NSString *const kFTUserPromoVideo;
extern NSString *const kFTUserObjectIdKey;
extern NSString *const kFTUserUsernameKey;
extern NSString *const kFTUserDisplayNameKey;
extern NSString *const kFTUserFirstnameKey;
extern NSString *const kFTUserLastnameKey;
extern NSString *const kFTUserInterestsKey;
extern NSString *const kFTUserBioKey;
extern NSString *const kFTUserFacebookIDKey;
extern NSString *const kFTUserPhotoIDKey;
extern NSString *const kFTUserProfilePicSmallKey;
extern NSString *const kFTUserProfilePicMediumKey;
extern NSString *const kFTUserFacebookFriendsKey;
extern NSString *const kFTUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kFTUserLocationKey;
extern NSString *const kFTUserTypeKey;
extern NSString *const kFTUserCompanyNameKey;
extern NSString *const kFTUserAddressKey;
extern NSString *const kFTUserWebsiteKey;
extern NSString *const kFTUserDescriptionKey;
extern NSString *const kFTUserEmailKey;
extern NSString *const kFTUserPostCountKey;
extern NSString *const kFTUserRewardsEarnedKey;
extern NSString *const kFTUserLastLoginKey;
extern NSString *const kFTUserTwitterIdKey;
extern NSString *const kFTUserCoverPhotoKey;

// Type values
extern NSString *const kFTUserTypeUser;
extern NSString *const kFTUserTypeAmbassador;
extern NSString *const kFTUserTypeBusiness;

#pragma mark - PFObject Place Class

// Class key
extern NSString *const kFTPlaceClassKey;

// Field keys
extern NSString *const kFTPlaceNameKey;
extern NSString *const kFTPlaceDescriptionKey;
extern NSString *const kFTPlaceLocationKey;
extern NSString *const kFTPlaceVerifiedKey;
extern NSString *const kFTPlaceIconKey;
extern NSString *const kFTPlaceContactKey;

#pragma mark - PFObject Location Class

// Class key
extern NSString *const kFTLocationClassKey;

// Field keys
extern NSString *const kFTLocationAddressKey;
extern NSString *const kFTLocationCityKey;
extern NSString *const kFTLocationStateKey;
extern NSString *const kFTLocationPostalCodeKey;
extern NSString *const kFTLocationCountryKey;
extern NSString *const kFTLocationGeoPointKey;

#pragma mark - Cached Post Attributes

// keys
extern NSString *const kFTPostAttributesIsLikedByCurrentUserKey;
extern NSString *const kFTPostAttributesLikeCountKey;
extern NSString *const kFTPostAttributesLikersKey;
extern NSString *const kFTPostAttributesCommentCountKey;
extern NSString *const kFTPostAttributesCommentersKey;
extern NSString *const kFTPostAttributesDisplayNameKey;

#pragma mark - Cached User Attributes

// keys
extern NSString *const kFTUserAttributesPostCountKey;
extern NSString *const kFTUserAttributesIsFollowedByCurrentUserKey;

#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kFTPushPayloadPayloadTypeKey;
extern NSString *const kFTPushPayloadPayloadTypeActivityKey;

extern NSString *const kFTPushPayloadActivityTypeKey;
extern NSString *const kFTPushPayloadActivityLikeKey;
extern NSString *const kFTPushPayloadActivityCommentKey;
extern NSString *const kFTPushPayloadActivityFollowKey;
extern NSString *const kFTPushPayloadActivityMentionKey;
extern NSString *const kFTPushPayloadActivityRewardKey;

extern NSString *const kFTPushPayloadFromUserObjectIdKey;
extern NSString *const kFTPushPayloadToUserObjectIdKey;
extern NSString *const kFTPushPayloadPostObjectIdKey;

#pragma mark - FaceBook Keys
extern NSString *const FBUserFirstNameKey;
extern NSString *const FBUserLastNameKey;
extern NSString *const FBUserNameKey;
extern NSString *const FBUserEmailKey;
extern NSString *const FBUserIDKey;
