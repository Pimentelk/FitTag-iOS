//
//  Constants.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTConstants.h"

NSString *const kFTUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kFTUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kFTLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const FTAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const FTUtilityUserFollowingChangedNotification                      = @"com.parse.Anypic.utility.userFollowingChanged";
NSString *const FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.parse.Anypic.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const FTUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Anypic.utility.didFinishProcessingProfilePictureNotification";
NSString *const FTTabBarControllerDidFinishEditingPhotoNotification            = @"com.parse.Anypic.tabBarController.didFinishEditingPhoto";
NSString *const FTTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const FTPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedPhoto";
NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.parse.Anypic.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kFTEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPFTInstallationUserKey = @"user";

#pragma mark - Activity Class
// Class key
NSString *const kFTActivityClassKey = @"Activity";

// Field keys
NSString *const kFTActivityTypeKey        = @"type";
NSString *const kFTActivityFromUserKey    = @"fromUser";
NSString *const kFTActivityToUserKey      = @"toUser";
NSString *const kFTActivityContentKey     = @"content";
NSString *const kFTActivityPhotoKey       = @"photo";

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

#pragma mark - Photo Class
// Class key
NSString *const kFTPhotoClassKey = @"Photo";

// Field keys
NSString *const kFTPhotoPictureKey         = @"image";
NSString *const kFTPhotoThumbnailKey       = @"thumbnail";
NSString *const kFTPhotoUserKey            = @"user";
NSString *const kFTPhotoOpenGraphIDKey     = @"fbOpenGraphID";

#pragma mark - Cached Photo Attributes
// keys
NSString *const kFTPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kFTPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kFTPhotoAttributesLikersKey               = @"likers";
NSString *const kFTPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kFTPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kFTUserAttributesPhotoCountKey                 = @"photoCount";
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