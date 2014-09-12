//
//  Constants.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTConstants.h"

NSString *const kFTUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.fittag.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kFTUserDefaultsCacheFacebookFriendsKey                     = @"com.fittag.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kFTLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const FTAppDelegateApplicationDidReceiveRemoteNotification           = @"com.fittag.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const FTUtilityUserFollowingChangedNotification                      = @"com.fittag.utility.userFollowingChanged";
NSString *const FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.fittag.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification     = @"com.fittag.utility.userLikedUnlikedVideoCallbackFinished";
NSString *const FTUtilityDidFinishProcessingProfilePictureNotification         = @"com.fittag.utility.didFinishProcessingProfilePictureNotification";
NSString *const FTTabBarControllerDidFinishEditingPhotoNotification            = @"com.fittag.tabBarController.didFinishEditingPhoto";
NSString *const FTTabBarControllerDidFinishImageFileUploadNotification         = @"com.fittag.tabBarController.didFinishImageFileUploadNotification";
NSString *const FTPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.fittag.photoDetailsViewController.userDeletedPhoto";
NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.fittag.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.fittag.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const FTVideoDetailsViewControllerUserLikedUnlikedVideoNotificationUserInfoLikedKey = @"liked";
NSString *const kFTEditPhotoViewControllerUserInfoCommentKey = @"comment";
NSString *const kFTEditVideoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kFTUserClassKey         = @"user";
NSString *const kPFTInstallationUserKey = @"user";

#pragma mark - Activity Class
// Class key
NSString *const kFTActivityClassKey = @"Activity";

// Field keys
NSString *const kFTActivityTypeKey        = @"type";
NSString *const kFTActivityFromUserKey    = @"fromUser";
NSString *const kFTActivityToUserKey      = @"toUser";
NSString *const kFTActivityContentKey     = @"content";
NSString *const kFTActivityPhotoKey       = @"post";
NSString *const kFTActivityVideoKey       = @"post";
NSString *const kFTActivityPostKey        = @"post";
NSString *const kFTActivityHashtag        = @"hashtag";
NSString *const kFTActivityMention        = @"mention";

// Type values
NSString *const kFTActivityTypeLike       = @"like";
NSString *const kFTActivityTypeFollow     = @"follow";
NSString *const kFTActivityTypeComment    = @"comment";
NSString *const kFTActivityTypeJoined     = @"joined";

#pragma mark - User Class
// Field keys
NSString *const kFTUserDisplayNameKey                          = @"displayName";
NSString *const kFTUserFirstname                               = @"firstname";
NSString *const kFTUserlastname                                = @"lastname";
NSString *const kFTUserInterests                               = @"interests";
NSString *const kFTUserBio                                     = @"bio";
NSString *const kFTUserFacebookIDKey                           = @"facebookId";
NSString *const kFTUserPhotoIDKey                              = @"photoId";
NSString *const kFTUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kFTUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kFTUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kFTUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kFTUserLocationKey                             = @"location";

#pragma mark - PFObject Post Class
NSString *const kFTPostClassKey = @"Post";

NSString *const kFTPostImageKey             = @"image";
NSString *const kFTPostVideoKey             = @"video";
NSString *const kFTPostKey                  = @"post";
NSString *const kFTPostUserKey              = @"user";
NSString *const kFTPostThumbnailKey         = @"thumbnail";
NSString *const kFTPostTypeKey              = @"type";
NSString *const kFTPostOpenGraphIDKey       = @"fbOpenGraphID";
NSString *const kFTPostLocationKey          = @"location";

#pragma mark - PFObject Video Class
// Class key
//NSString *const kFTVideoClassKey = @"Post";

// Field keys
//NSString *const kFTVideoImageKey             = @"image";
//NSString *const kFTVideoKey                  = @"video";
//NSString *const kFTVideoUserKey              = @"user";
//NSString *const kFTVideoOpenGraphIDKey       = @"fbOpenGraphID";

#pragma mark - Cached Video Attributes
// keys
NSString *const kFTVideoAttributesIsLikedByCurrentUserKey   = @"isLikedByCurrentUser";
NSString *const kFTVideoAttributesLikeCountKey              = @"likeCount";
NSString *const kFTVideoAttributesLikersKey                 = @"likers";
NSString *const kFTVideoAttributesCommentCountKey           = @"commentCount";
NSString *const kFTVideoAttributesCommentersKey             = @"commenters";
NSString *const kFTVideoAttributesDisplayName               = @"displayName";

#pragma mark - Photo Class
// Class key
//NSString *const kFTPhotoClassKey = @"Post";

// Field keys
//NSString *const kFTPhotoPictureKey         = @"image";
//NSString *const kFTPhotoThumbnailKey       = @"thumbnail";
//NSString *const kFTPhotoUserKey            = @"user";
//NSString *const kFTPhotoOpenGraphIDKey     = @"fbOpenGraphID";

#pragma mark - Cached Photo Attributes
// keys
NSString *const kFTPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kFTPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kFTPhotoAttributesLikersKey               = @"likers";
NSString *const kFTPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kFTPhotoAttributesCommentersKey           = @"commenters";
NSString *const kFTPhotoAttributesDisplayName             = @"displayName";

#pragma mark - Cached User Attributes
// keys
NSString *const kFTUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kFTUserAttributesVideoCountKey                 = @"videoCount";
NSString *const kFTUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kFTPushPayloadPayloadTypeKey          = @"p";
NSString *const kFTPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kFTPushPayloadActivityTypeKey     = @"t";
NSString *const kFTPushPayloadActivityLikeKey     = @"l";
NSString *const kFTPushPayloadActivityCommentKey  = @"c";
NSString *const kFTPushPayloadActivityFollowKey   = @"f";

NSString *const kFTPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kFTPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kFTPushPayloadPhotoObjectIdKey    = @"pid";