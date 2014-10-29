//
//  Constants.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTConstants.h"

#pragma mark - AppStoreURLFormat
NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";

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
NSString *const kFTUserClassKey         = @"_User";
NSString *const kPFTInstallationUserKey = @"user";

#pragma mark - Activity Class

// Class key
NSString *const kFTActivityClassKey = @"Activity";

// Field keys
NSString *const kFTActivityTypeKey        = @"type";
NSString *const kFTActivityFromUserKey    = @"fromUser";
NSString *const kFTActivityToUserKey      = @"toUser";
NSString *const kFTActivityContentKey     = @"content";
NSString *const kFTActivityPostKey        = @"post";
NSString *const kFTActivityHashtagKey     = @"hashtag";
NSString *const kFTActivityMentionKey     = @"mention";
NSString *const kFTActivityWordKey        = @"keyWords";
NSString *const kFTActivityRewardsKey     = @"rewards";

// Type values
NSString *const kFTActivityTypeLike       = @"like";
NSString *const kFTActivityTypeFollow     = @"follow";
NSString *const kFTActivityTypeComment    = @"comment";
NSString *const kFTActivityTypeJoined     = @"joined";
NSString *const kFTActivityTypeReward     = @"reward";

#pragma mark - User Class

// Field keys
NSString *const kFTUserObjectIdKey                             = @"objectId";
NSString *const kFTUserUsernameKey                             = @"username";
NSString *const kFTUserDisplayNameKey                          = @"displayName";
NSString *const kFTUserFirstnameKey                            = @"firstname";
NSString *const kFTUserLastnameKey                             = @"lastname";
NSString *const kFTUserInterestsKey                            = @"interests";
NSString *const kFTUserBioKey                                  = @"bio";
NSString *const kFTUserFacebookIDKey                           = @"facebookId";
NSString *const kFTUserPhotoIDKey                              = @"photoId";
NSString *const kFTUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kFTUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kFTUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kFTUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kFTUserLocationKey                             = @"location";
NSString *const kFTUserTypeKey                                 = @"type";
NSString *const kFTUserCompanyNameKey                          = @"companyName";
NSString *const kFTUserAddressKey                              = @"address";
NSString *const kFTUserWebsiteKey                              = @"website";
NSString *const kFTUserDescriptionKey                          = @"description";
NSString *const kFTUserEmailKey                                = @"email";
NSString *const kFTUserPostCountKey                            = @"postCount";
NSString *const kFTUserRewardsEarnedKey                        = @"rewardsEarned";
NSString *const kFTUserLastLoginKey                            = @"lastLogin";
NSString *const kFTUserTwitterIdKey                            = @"twitterId";
NSString *const kFTUserCoverPhotoKey                           = @"coverPhoto";
// Type values
NSString *const kFTUserTypeUser                                = @"user";
NSString *const kFTUserTypeAmbassador                          = @"ambassador";
NSString *const kFTUserTypeBusiness                            = @"business";

#pragma mark - PFObject Interest Class

// Class key
NSString *const kFTInterestsClassKey                           = @"Interests";

// Field keys
NSString *const kFTInterestKey                                 = @"interest";

#pragma mark - PFObject Rewards Class

// Class key
NSString *const kFTRewardsClassKey          = @"Rewards";

// Field keys
NSString *const kFTRewardsNameKey           = @"name";
NSString *const kFTRewardsDescriptionKey    = @"description";
NSString *const kFTRewardsTypeKey           = @"type";
NSString *const kFTRewardsUserKey           = @"user";
NSString *const kFTRewardsExpiredKey        = @"expiredAt";
NSString *const kFTRewardsImageKey          = @"image";
NSString *const kFTRewardsStatusKey         = @"status";

// Type keys
NSString *const kFTRewardsTypeActive        = @"ACTIVE";
NSString *const kFTRewardsTypeInactive      = @"INACTIVE";
NSString *const kFTRewardsTypeUsed          = @"USED";
NSString *const kFTRewardsTypeExpired       = @"EXPIRED";

#pragma mark - PFObject Post Class

NSString *const kFTPostClassKey = @"Post";

NSString *const kFTPostKey                  = @"post";
NSString *const kFTPostImageKey             = @"image";
NSString *const kFTPostVideoKey             = @"video";
NSString *const kFTPostUserKey              = @"user";
NSString *const kFTPostThumbnailKey         = @"thumbnail";
NSString *const kFTPostTypeKey              = @"type";
NSString *const kFTPostOpenGraphIDKey       = @"fbOpenGraphID";
NSString *const kFTPostLocationKey          = @"location";
NSString *const kFTPostPostsKey             = @"posts";

NSString *const kFTPostTypeGallery          = @"gallery";
NSString *const kFTPostTypeGalleryImage     = @"galleryImage";
NSString *const kFTPostTypeGalleryVideo     = @"galleryVideo";
NSString *const kFTPostTypeImage            = @"image";
NSString *const kFTPostTypeVideo            = @"video";

#pragma mark - Cached Post Attributes

// keys
NSString *const kFTPostAttributesIsLikedByCurrentUserKey   = @"isLikedByCurrentUser";
NSString *const kFTPostAttributesLikeCountKey              = @"likeCount";
NSString *const kFTPostAttributesLikersKey                 = @"likers";
NSString *const kFTPostAttributesCommentCountKey           = @"commentCount";
NSString *const kFTPostAttributesCommentersKey             = @"commenters";
NSString *const kFTPostAttributesDisplayNameKey            = @"displayName";
#pragma mark - Cached User Attributes

// keys
NSString *const kFTUserAttributesPostCountKey                  = @"postCount";
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

#pragma mark - FaceBook Keys
NSString *const FBUserFirstNameKey  = @"first_name";
NSString *const FBUserLastNameKey   = @"last_name";
NSString *const FBUserNameKey       = @"name";
NSString *const FBUserEmailKey      = @"email";
NSString *const FBUserIDKey         = @"id";


