//
//  FTUtility.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTUtility : NSObject
+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)likeVideoInBackground:(id)video block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeVideoInBackground:(id)video block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

//+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (void)prepareToSharePostOnFacebook:(PFObject *)post;
+ (void)prepareToSharePostOnTwitter:(PFObject *)post;
+ (void)shareCapturedMomentOnFacebook:(NSMutableDictionary *)moment;
+ (void)shareCapturedMomentOnTwitter:(NSString *)status;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user block:(void (^)(NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;
+ (NSDictionary*)parseURLParams:(NSString *)query;

+ (NSString *)getLowercaseStringWithoutSymbols:(NSString *)mention;

+ (NSArray *)extractHashtagsFromText:(NSString *)text;
+ (NSArray *)extractMentionsFromText:(NSString *)text;

+ (void)showHudMessage:(NSString *)message WithDuration:(NSTimeInterval)duration;

//+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
//+ (PFQuery *)queryForActivitiesOnVideo:(PFObject *)video cachePolicy:(PFCachePolicy)cachePolicy;
//+ (PFQuery *)queryForActivitiesOnGallery:(PFObject *)gallery cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForActivitiesOnPost:(PFObject *)post cachePolicy:(PFCachePolicy)cachePolicy;
@end
