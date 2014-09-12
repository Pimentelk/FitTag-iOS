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
    FTOffersTabBarItemIndex = 3,
    FTEmptyTabBarItemIndex = 4
} FTTabBarControllerViewControllerIndex;

#pragma mark - NSUserDefaults
extern NSString *const kFTUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kFTUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs
extern NSString *const kFTLaunchURLHostTakePicture;

#pragma mark - NSNotification
extern NSString *const FTAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const FTUtilityUserFollowingChangedNotification;
extern NSString *const FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification;
extern NSString *const FTUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const FTTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const FTTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const FTPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification;

#pragma mark - User Info Keys
extern NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const FTVideoDetailsViewControllerUserLikedUnlikedVideoNotificationUserInfoLikedKey;
extern NSString *const kFTEditPhotoViewControllerUserInfoCommentKey;
extern NSString *const kFTEditVideoViewControllerUserInfoCommentKey;

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
extern NSString *const kFTActivityPhotoKey;
extern NSString *const kFTActivityVideoKey;
extern NSString *const kFTActivityPostKey;
extern NSString *const kFTActivityHashtagKey;
extern NSString *const kFTActivityMentionKey;

// Type values
extern NSString *const kFTActivityTypeLike;
extern NSString *const kFTActivityTypeFollow;
extern NSString *const kFTActivityTypeComment;
extern NSString *const kFTActivityTypeJoined;

#pragma mark - PFObject Post Class
extern NSString *const kFTPostClassKey;

// Field keys
extern NSString *const kFTPostImageKey;
extern NSString *const kFTPostVideoKey;
extern NSString *const kFTPostKey;
extern NSString *const kFTPostUserKey;
extern NSString *const kFTPostThumbnailKey;
extern NSString *const kFTPostTypeKey;
extern NSString *const kFTPostOpenGraphIDKey;
extern NSString *const kFTPostLocationKey;

#pragma mark - PFObject User Class

// Class key
extern NSString *const kFTUserClassKey;

// Field keys
extern NSString *const kFTUserDisplayNameKey;
extern NSString *const kFTUserFirstnameKey;
extern NSString *const kFTUserlastnameKey;
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

// Type values
extern NSString *const kFTUserTypeUser;
extern NSString *const kFTUserTypeAmbassador;
extern NSString *const kFTUserTypeBusiness;

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
//extern NSString *const kFTUserAttributesPhotoCountKey;
//extern NSString *const kFTUserAttributesVideoCountKey;
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

extern NSString *const kFTPushPayloadFromUserObjectIdKey;
extern NSString *const kFTPushPayloadToUserObjectIdKey;
extern NSString *const kFTPushPayloadPhotoObjectIdKey;