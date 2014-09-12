//
//  FTCache.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCache.h"

@interface FTCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
@end

@implementation FTCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - FTCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kFTPhotoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kFTPhotoAttributesLikeCountKey,
                                likers,kFTPhotoAttributesLikersKey,
                                @([commenters count]),kFTPhotoAttributesCommentCountKey,
                                commenters,kFTPhotoAttributesCommentersKey,
                                photo[@"user"][@"displayName"],kFTPhotoAttributesDisplayName,
                                nil];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setAttributesForVideo:(PFObject *)video likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:likedByCurrentUser],kFTVideoAttributesIsLikedByCurrentUserKey,
                                @([likers count]),kFTVideoAttributesLikeCountKey,
                                likers,kFTVideoAttributesLikersKey,
                                @([commenters count]),kFTVideoAttributesCommentCountKey,
                                commenters,kFTVideoAttributesCommentersKey,
                                video[@"user"][@"displayName"],kFTVideoAttributesDisplayName,
                                nil];
    [self setAttributes:attributes forVideo:video];
}

- (NSDictionary *)attributesForPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForVideo:(PFObject *)video {
    NSString *key = [self keyForVideo:video];
    return [self.cache objectForKey:key];
}

- (NSNumber *)likeCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kFTPhotoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)likeCountForVideo:(PFObject *)video {
    NSDictionary *attributes = [self attributesForVideo:video];
    if (attributes) {
        return [attributes objectForKey:kFTVideoAttributesLikeCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kFTPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForVideo:(PFObject *)video {
    NSDictionary *attributes = [self attributesForVideo:video];
    if (attributes) {
        return [attributes objectForKey:kFTVideoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)likersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kFTPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)likersForVideo:(PFObject *)video {
    NSDictionary *attributes = [self attributesForPhoto:video];
    if (attributes) {
        return [attributes objectForKey:kFTVideoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kFTPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForVideo:(PFObject *)video {
    NSDictionary *attributes = [self attributesForVideo:video];
    if (attributes) {
        return [attributes objectForKey:kFTVideoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)displayNameForPhoto:(PFObject *)photo{
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if(attributes){
        return [attributes objectForKey:kFTPhotoAttributesDisplayName];
    }
    
    return [NSArray array];
}

- (NSArray *)displayNameForVideo:(PFObject *)video{
    NSDictionary *attributes = [self attributesForVideo:video];
    if(attributes){
        return [attributes objectForKey:kFTVideoAttributesDisplayName];
    }
    
    return [NSArray array];
}

- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kFTPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setVideoIsLikedByCurrentUser:(PFObject *)video liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForVideo:video]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kFTVideoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forVideo:video];
}

- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [[attributes objectForKey:kFTPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (BOOL)isVideoLikedByCurrentUser:(PFObject *)video {
    NSDictionary *attributes = [self attributesForVideo:video];
    if (attributes) {
        return [[attributes objectForKey:kFTVideoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kFTPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)incrementLikerCountForVideo:(PFObject *)video {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:video] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForVideo:video]];
    [attributes setObject:likerCount forKey:kFTVideoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:video];
}

- (void)decrementLikerCountForPhoto:(PFObject *)photo {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:likerCount forKey:kFTPhotoAttributesLikeCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementLikerCountForVideo:(PFObject *)video {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForVideo:video] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForVideo:video]];
    [attributes setObject:likerCount forKey:kFTVideoAttributesLikeCountKey];
    [self setAttributes:attributes forVideo:video];
}

- (void)incrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kFTPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)incrementCommentCountForVideo:(PFObject *)video{
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForVideo:video] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForVideo:video]];
    [attributes setObject:commentCount forKey:kFTVideoAttributesCommentCountKey];
    [self setAttributes:attributes forVideo:video];
}

- (void)decrementCommentCountForPhoto:(PFObject *)photo {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:commentCount forKey:kFTPhotoAttributesCommentCountKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)decrementCommentCountForVideo:(PFObject *)video {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForVideo:video] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForVideo:video]];
    [attributes setObject:commentCount forKey:kFTVideoAttributesCommentCountKey];
    [self setAttributes:attributes forVideo:video];
}

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kFTUserAttributesPhotoCountKey,
                                [NSNumber numberWithBool:following],kFTUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (void)setAttributesForUser:(PFUser *)user videoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kFTUserAttributesVideoCountKey,
                                [NSNumber numberWithBool:following],kFTUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kFTUserAttributesPhotoCountKey];
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)videoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *videoCount = [attributes objectForKey:kFTUserAttributesVideoCountKey];
        if (videoCount) {
            return videoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kFTUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }
    
    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kFTUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setVideoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kFTUserAttributesVideoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kFTUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kFTUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kFTUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forVideo:(PFObject *)video {
    NSString *key = [self keyForVideo:video];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForVideo:(PFObject *)video{
    return [NSString stringWithFormat:@"video_%@", [video objectId]];
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end

