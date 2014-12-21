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
//https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Food%20Sh&sensor=false&radius=500&location=0,0&key=
//https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@
//https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=AddYourOwnKeyHere&input=pizza+near%20par
NSString *const googleMapsAPIPlaceAutocompleteURL = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&sensor=false&radius=%d&location=%f,%f&key=%@";
NSString *const googleMapsAPIPlaceSearchURL = @"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@";
NSString *const googleMapsAPIPlaceQueryURL = @"https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=%@&input=%@";

#pragma mark - NSUserDefaults
NSString *const kFTUserDefaultsSettingsViewControllerPushLikesKey          = @"com.fittag.userDefaults.settingsDetailViewController.pushLikes";
NSString *const kFTUserDefaultsSettingsViewControllerPushCommentsKey       = @"com.fittag.userDefaults.settingsDetailViewController.pushComments";
NSString *const kFTUserDefaultsSettingsViewControllerPushMentionsKey       = @"com.fittag.userDefaults.settingsDetailViewController.pushMentions";
NSString *const kFTUserDefaultsSettingsViewControllerPushFollowsKey        = @"com.fittag.userDefaults.settingsDetailViewController.pushFollows";
NSString *const kFTUserDefaultsSettingsViewControllerPushRewardsKey        = @"com.fittag.userDefaults.settingsDetailViewController.pushRewards";
NSString *const kFTUserDefaultsSettingsViewControllerPushBusinessesKey     = @"com.fittag.userDefaults.settingsDetailViewController.pushBusinesses";
NSString *const kFTUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.fittag.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kFTUserDefaultsCacheFacebookFriendsKey                     = @"com.fittag.userDefaults.cache.facebookFriends";

#pragma mark - Launch URLs

NSString *const kFTLaunchURLHostTakePicture = @"camera";

#pragma mark - NSNotification

// Profile
NSString *const FTProfileDidChangeBioNotification                                   = @"com.fittag.userProfileViewController.profileDidChangeBioNotification";
NSString *const FTProfileDidChangeProfilePhotoNotification                          = @"com.fittag.userProfileViewController.profileDidChangeProfilePhotoNotification";
NSString *const FTProfileDidChangeCoverPhotoNotification                            = @"com.fittag.userProfileViewController.profileDidChangeCoverPhotoNotification";

// Remote
NSString *const FTAppDelegateApplicationDidReceiveRemoteNotification                = @"com.fittag.appDelegate.applicationDidReceiveRemoteNotification";

// Utilities
NSString *const FTUtilityUserFollowersChangedNotification                           = @"com.fittag.utility.userFollowersChanged";
NSString *const FTUtilityUserFollowingChangedNotification                           = @"com.fittag.utility.userFollowingChanged";
NSString *const FTUtilityBusinessFollowingChangedNotification                       = @"com.fittag.utility.businessFollowingChanged";
NSString *const FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification          = @"com.fittag.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification          = @"com.fittag.utility.userLikedUnlikedVideoCallbackFinished";
NSString *const FTUtilityDidFinishProcessingProfilePictureNotification              = @"com.fittag.utility.didFinishProcessingProfilePictureNotification";

// Tabbar
NSString *const FTTabBarControllerDidFinishEditingPhotoNotification                 = @"com.fittag.tabBarController.didFinishEditingPhoto";
NSString *const FTTabBarControllerDidFinishImageFileUploadNotification              = @"com.fittag.tabBarController.didFinishImageFileUploadNotification";

// Timeline
NSString *const FTTimelineViewControllerUserDeletedPostNotification                 = @"com.fittag.timelineViewController.userDeletedPhoto";

// Post
NSString *const FTPostDetailsViewControllerUserLikedUnlikedPhotoNotification        = @"com.fittag.photoDetailsViewController.userLikedUnlikedPostInDetailsViewNotification";
NSString *const FTPostDetailsViewControllerUserCommentedOnPhotoNotification         = @"com.fittag.photoDetailsViewController.userCommentedOnPostInDetailsViewNotification";

// Reward
NSString *const FTRewardsCollectionViewControllerUserReceiveRewardNotification      = @"com.fittag.rewardsCollectionViewController.userDidRedeemRewardNotification";

#pragma mark - User Info Keys
NSString *const FTPostDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kFTEditPostViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kFTInstallationUserKey  = @"user";

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
NSString *const kFTActivityRewardKey      = @"reward";

// Type values
NSString *const kFTActivityTypeLike       = @"like";
NSString *const kFTActivityTypeFollow     = @"follow";
NSString *const kFTActivityTypeComment    = @"comment";
NSString *const kFTActivityTypeJoined     = @"joined";
NSString *const kFTActivityTypeRedeem     = @"redeem";
NSString *const kFTActivityTypeDelete     = @"delete";
NSString *const kFTActivityTypeBlock      = @"block";
NSString *const kFTActivityTypeMention    = @"mention";
NSString *const kFTActivityTypeOffer      = @"offer";

#pragma mark - User Class

// Class key
NSString *const kFTUserClassKey = @"_User";

// Field keys
NSString *const kFTUserPromoVideo                              = @"promoVideo";
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
NSString *const kFTRewardClassKey          = @"Reward";

// Field keys
NSString *const kFTRewardNameKey           = @"name";
NSString *const kFTRewardDescriptionKey    = @"description";
NSString *const kFTRewardTypeKey           = @"type";
NSString *const kFTRewardUserKey           = @"user";
NSString *const kFTRewardExpiredKey        = @"expiredAt";
NSString *const kFTRewardImageKey          = @"image";
NSString *const kFTRewardStatusKey         = @"status";

// Type keys
NSString *const kFTRewardTypeActive        = @"ACTIVE";
NSString *const kFTRewardTypeInactive      = @"INACTIVE";
NSString *const kFTRewardTypeUsed          = @"USED";
NSString *const kFTRewardTypeExpired       = @"EXPIRED";

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
NSString *const kFTPostHashTagKey           = @"hashTags";
NSString *const kFTPostMentionKey           = @"mentions";
NSString *const kFTPostCaptionKey           = @"caption";

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
NSString *const kFTPushPayloadActivityMentionKey  = @"m";
NSString *const kFTPushPayloadActivityRewardKey   = @"r";

NSString *const kFTPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kFTPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kFTPushPayloadPostObjectIdKey    = @"pid";

#pragma mark - FaceBook Keys
NSString *const FBUserFirstNameKey  = @"first_name";
NSString *const FBUserLastNameKey   = @"last_name";
NSString *const FBUserNameKey       = @"name";
NSString *const FBUserEmailKey      = @"email";
NSString *const FBUserIDKey         = @"id";


