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
- (void)setAttributesForPost:(PFObject *)post
                      likers:(NSArray *)likers
                  commenters:(NSArray *)commenters
          likedByCurrentUser:(BOOL)likedByCurrentUser;

- (NSDictionary *)attributesForPost:(PFObject *)post;
- (NSNumber *)likeCountForPost:(PFObject *)post;
- (NSNumber *)commentCountForPost:(PFObject *)post;
- (NSArray *)likersForPost:(PFObject *)post;
- (NSArray *)commentersForPost:(PFObject *)post;
//- (NSString *)displayNameForPost:(PFObject *)post;
- (void)setPostIsLikedByCurrentUser:(PFObject *)post liked:(BOOL)liked;
- (BOOL)isPostLikedByCurrentUser:(PFObject *)post;
- (void)incrementLikerCountForPost:(PFObject *)post;
- (void)decrementLikerCountForPost:(PFObject *)post;
- (void)incrementCommentCountForPost:(PFObject *)post;
- (void)decrementCommentCountForPost:(PFObject *)post;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)postCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPostCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;
- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
