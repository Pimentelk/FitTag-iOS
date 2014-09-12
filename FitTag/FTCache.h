//
//  FTCache.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setAttributesForVideo:(PFObject *)video likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (NSDictionary *)attributesForPhoto:(PFObject *)photo;
- (NSDictionary *)attributesForVideo:(PFObject *)video;
- (NSNumber *)likeCountForPhoto:(PFObject *)photo;
- (NSNumber *)likeCountForVideo:(PFObject *)video;
- (NSNumber *)commentCountForPhoto:(PFObject *)photo;
- (NSNumber *)commentCountForVideo:(PFObject *)video;
- (NSArray *)likersForPhoto:(PFObject *)photo;
- (NSArray *)likersForVideo:(PFObject *)video;
- (NSArray *)commentersForPhoto:(PFObject *)photo;
- (NSArray *)commentersForVideo:(PFObject *)video;
- (NSString *)displayNameForPhoto:(PFObject *)photo;
- (NSString *)displayNameForVideo:(PFObject *)video;
- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked;
- (void)setVideoIsLikedByCurrentUser:(PFObject *)video liked:(BOOL)liked;
- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo;
- (BOOL)isVideoLikedByCurrentUser:(PFObject *)video;
- (void)incrementLikerCountForPhoto:(PFObject *)photo;
- (void)incrementLikerCountForVideo:(PFObject *)video;
- (void)decrementLikerCountForPhoto:(PFObject *)photo;
- (void)decrementLikerCountForVideo:(PFObject *)video;
- (void)incrementCommentCountForPhoto:(PFObject *)photo;
- (void)incrementCommentCountForVideo:(PFObject *)photo;
- (void)decrementCommentCountForPhoto:(PFObject *)photo;
- (void)decrementCommentCountForVideo:(PFObject *)photo;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (NSNumber *)videoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setVideoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
