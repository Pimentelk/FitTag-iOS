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

// Type values
extern NSString *const kFTActivityTypeLike;
extern NSString *const kFTActivityTypeFollow;
extern NSString *const kFTActivityTypeComment;
extern NSString *const kFTActivityTypeJoined;

#pragma mark - PFObject Post Class
extern NSString *const kFTPostClassName;

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kFTUserDisplayNameKey;
extern NSString *const kFTUserFacebookIDKey;
extern NSString *const kFTUserPhotoIDKey;
extern NSString *const kFTUserProfilePicSmallKey;
extern NSString *const kFTUserProfilePicMediumKey;
extern NSString *const kFTUserFacebookFriendsKey;
extern NSString *const kFTUserAlreadyAutoFollowedFacebookFriendsKey;

#pragma mark - PFObject Video Class
// Class key
extern NSString *const kFTVideoClassKey;

// Field keys
extern NSString *const kFTVideoImageKey;
extern NSString *const kFTVideoKey;
extern NSString *const kFTVideoUserKey;
extern NSString *const kFTVideoOpenGraphIDKey;

#pragma mark - Cached Video Attributes
// keys
extern NSString *const kFTVideoAttributesIsLikedByCurrentUserKey;
extern NSString *const kFTVideoAttributesLikeCountKey;
extern NSString *const kFTVideoAttributesLikersKey;
extern NSString *const kFTVideoAttributesCommentCountKey;
extern NSString *const kFTVideoAttributesCommentersKey;

#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kFTPhotoClassKey;

// Field keys
extern NSString *const kFTPhotoPictureKey;
extern NSString *const kFTPhotoThumbnailKey;
extern NSString *const kFTPhotoUserKey;
extern NSString *const kFTPhotoOpenGraphIDKey;

#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kFTPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kFTPhotoAttributesLikeCountKey;
extern NSString *const kFTPhotoAttributesLikersKey;
extern NSString *const kFTPhotoAttributesCommentCountKey;
extern NSString *const kFTPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kFTUserAttributesPhotoCountKey;
extern NSString *const kFTUserAttributesVideoCountKey;
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