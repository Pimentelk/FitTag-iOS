//
//  FTUtility.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

//
//  FTUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "FTUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation FTUtility

#pragma mark - FTUtility
#pragma mark Like Photos

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryExistingLikes whereKey:kFTActivityPostKey equalTo:photo];
    [queryExistingLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    [queryExistingLikes whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kFTActivityClassKey];
        [likeActivity setObject:kFTActivityTypeLike forKey:kFTActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kFTPostUserKey] forKey:kFTActivityToUserKey];
        [likeActivity setObject:photo forKey:kFTActivityPostKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kFTPostUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [FTUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike] && [activity objectForKey:kFTActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment] && [activity objectForKey:kFTActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    [[FTCache sharedCache] setAttributesForPost:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}

+ (void)likeVideoInBackground:(id)video block:(void (^)(BOOL succeeded, NSError *error))completionBlock{
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryExistingLikes whereKey:kFTActivityPostKey equalTo:video];
    [queryExistingLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    [queryExistingLikes whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kFTActivityClassKey];
        [likeActivity setObject:kFTActivityTypeLike forKey:kFTActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
        [likeActivity setObject:[video objectForKey:kFTPostUserKey] forKey:kFTActivityToUserKey];
        [likeActivity setObject:video forKey:kFTActivityPostKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[video objectForKey:kFTPostUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [FTUtility queryForActivitiesOnPost:video cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike] && [activity objectForKey:kFTActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment] && [activity objectForKey:kFTActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[FTCache sharedCache] setAttributesForPost:video likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification object:video userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:FTVideoDetailsViewControllerUserLikedUnlikedVideoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
}

+ (void)unlikeVideoInBackground:(id)video block:(void (^)(BOOL succeeded, NSError *error))completionBlock{
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryExistingLikes whereKey:kFTActivityPostKey equalTo:video];
    [queryExistingLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    [queryExistingLikes whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteInBackground];
            }
            
            //NSLog(@"completionBlock = %@", completionBlock);
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [FTUtility queryForActivitiesOnPost:video cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    [[FTCache sharedCache] setAttributesForPost:video likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserLikedUnlikedVideoCallbackFinishedNotification object:video userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:FTVideoDetailsViewControllerUserLikedUnlikedVideoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryExistingLikes whereKey:kFTActivityPostKey equalTo:photo];
    [queryExistingLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    [queryExistingLikes whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteInBackground];
            }
            
            //NSLog(@"completionBlock = %@", completionBlock);
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [FTUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[FTCache sharedCache] setAttributesForPost:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}


#pragma mark Facebook

/*
+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kFTUserProfilePicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kFTUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}
*/

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kFTUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kFTUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kFTUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

+ (void)makeRequestToPost:(NSMutableDictionary *)params {
    
    NSLog(@"makeRequestToPost:params");
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"makeRequestToPost:!error");
            // Success! Include your code to handle the results here
            // Make the request
            [FBRequestConnection startWithGraphPath:@"/me/feed"
                                         parameters:params
                                         HTTPMethod:@"POST"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          NSLog(@"startWithGraphPath:!error");
                                          
                                          // Link posted successfully to Facebook
                                          //NSLog(@"result: %@", result);
                                          [FTUtility showHudMessage:@"Shared to Facebook" WithDuration:3];
                                      } else {
                                          NSLog(@"startWithGraphPath:error");
                                          
                                          // An error occurred, we need to handle the error
                                          // See: https://developers.facebook.com/docs/ios/errors
                                          NSLog(@"%@", error.description);
                                          
                                          [[[UIAlertView alloc] initWithTitle:@"Error Posting"
                                                                      message:@"Oh oh! Something went very wrong, contact support and give them this code: BOOMPOW"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
            
        } else {
            NSLog(@"makeRequestToPost:error");
            
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}

+ (void)shareCapturedMomentOnFacebook:(NSMutableDictionary *)moment {
    NSLog(@"shareCaptureMomentOnFacebook:");
    // We will post a story on behalf of the user
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    //NSLog(@"FBSession.activeSession:%@",FBSession.activeSession);
    
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // Request the permissions the user currently has
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error){
                                      NSLog(@"shareCaptureMomentOnFacebook:!error");
                                      
                                      NSDictionary *currentPermissions = [(NSArray *)[result data] objectAtIndex:0];
                                      //NSLog(@"current permissions %@", currentPermissions);
                                      NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                      // Check if all the permissions we need are present in the user's current permissions
                                      // If they are not present add them to the permissions to be requested
                                      for (NSString *permission in permissionsNeeded){
                                          if (![currentPermissions objectForKey:permission]){
                                              [requestPermissions addObject:permission];
                                          }
                                      }
                                      
                                      NSLog(@"requestPermissions %@", requestPermissions);
                                      // If we have permissions to request
                                      if ([requestPermissions count] > 0){
                                          NSLog(@"shareCaptureMomentOnFacebook:[requestPermissions count] > 0");
                                          [[PFFacebookUtils session] requestNewPublishPermissions:requestPermissions
                                                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                                                completionHandler:^(FBSession *session, NSError *error) {
                                                                                    
                                                                                    NSLog(@"error:%@",error);
                                                                                    NSLog(@"session:%@",session);
                                                                                    
                                                                                    if (!error) {
                                                                                        NSLog(@"requestNewPublishPermissions:!error");
                                                                                        // Permission granted
                                                                                        NSLog(@"new permissions %@", [[PFFacebookUtils session] permissions]);
                                                                                        // We can request the user information
                                                                                        [self makeRequestToPost:moment];
                                                                                    } else {
                                                                                        NSLog(@"requestNewPublishPermissions:error");
                                                                                        
                                                                                        // An error occurred, we need to handle the error
                                                                                        // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                                        NSLog(@"error %@", error.description);
                                                                                        [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                                                                                                    message:@"Please visit the shared settings to link your FaceBook account."
                                                                                                                   delegate:nil
                                                                                                          cancelButtonTitle:@"OK"
                                                                                                          otherButtonTitles:nil] show];
                                                                                    }
                                                                                }];
                                      } else {
                                          NSLog(@"shareCaptureMomentOnFacebook:![requestPermissions count] > 0");
                                          
                                          // Permissions are present
                                          // We can request the user information
                                          [self makeRequestToPost:moment];
                                      }
                                      
                                  } else {
                                      NSLog(@"shareCaptureMomentOnFacebook:error");
                                      // An error occurred, we need to handle the error
                                      // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                      NSLog(@"error %@", error.description);
                                      [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                                                  message:@"Please visit the shared settings to link your FaceBook account."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil] show];
                                  }
                              }];
    } else {
        // permission exists
        // We can request the user information
        [self makeRequestToPost:moment];
    }
}

+ (void)prepareToSharePostOnFacebook:(PFObject *)post {
    NSLog(@"sharePostOnFacebook");
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        // Facebook account is linked
        NSString *description = EMPTY_STRING;
        PFFile *caption = nil;
        
        if ([post objectForKey:kFTPostImageKey]) {
            caption = [post objectForKey:kFTPostImageKey];
        }
        
        if (!post.objectId) {
            [[[UIAlertView alloc] initWithTitle:@"Post Error"
                                        message:@"There was a problem sharing this post to facebook."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        
        if (!caption) {
            [[[UIAlertView alloc] initWithTitle:@"Post Error"
                                        message:@"There was a problem sharing this post to facebook."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        
        NSString *link = [NSString stringWithFormat:@"http://fittag.com/viewer.php?pid=%@",post.objectId];
        
        if (caption.url) {
            [FTUtility shareCapturedMomentOnFacebook:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @"Captured Healthy Moment", @"name",
                                                      @"Healthy moment was shared via #FitTag.", @"caption",
                                                      description, @"description",
                                                      link, @"link",
                                                      caption.url, @"picture", nil]];
        }
        
    } else {
        
        NSLog(@"is not linked with user...");
        [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                    message:@"Please visit the shared settings to link your FaceBook account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    }
}

#pragma mark Twitter Update

+ (void)prepareToSharePostOnTwitter:(PFObject *)post {
    
    if (post && [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        NSString *status = [NSString stringWithFormat:@"Captured a healthy moment via #FitTag http://fittag.com/viewer.php?pid=%@",post.objectId];
        [FTUtility shareCapturedMomentOnTwitter:status];
        
    } else {
        // Twitter account is not linked
        [[[UIAlertView alloc] initWithTitle:@"Twitter Not Linked"
                                    message:@"Please visit the shared settings to link your Twitter account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

+ (void)shareCapturedMomentOnTwitter:(NSString *)status {
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        [FTUtility showHudMessage:@"Posting to Twitter" WithDuration:3];
        
        ACAccountStore *twitterAccountStore = [[ACAccountStore alloc] init];
        ACAccountType *TWaccountType= [twitterAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [twitterAccountStore requestAccessToAccountsWithType:TWaccountType
                                                     options:nil
                                                  completion:^(BOOL succeeded, NSError *error) {
                                                      if (!error) {
                                                          
                                                          NSArray *accounts = [twitterAccountStore accountsWithAccountType:TWaccountType];
                                                          //NSLog(@"accounts:%@",accounts);
                                                          
                                                          NSDictionary *dataDict = @{ @"status" : status };
                                                          NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                                                          SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                                  requestMethod:SLRequestMethodPOST
                                                                                                            URL:requestURL
                                                                                                     parameters:dataDict];
                                                          
                                                          request.account = [accounts lastObject];
                                                          [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                                                              if (!error) {
                                                                  
                                                                  NSLog(@"Not an error...");
                                                                  
                                                                  NSError *listError = nil;
                                                                  NSDictionary *list =[NSJSONSerialization JSONObjectWithData:data
                                                                                                                      options:kNilOptions
                                                                                                                        error:&listError];
                                                                  
                                                                  NSLog(@"list:%@",list);
                                                                  
                                                                  if (![list objectForKey:@"errors"]) {
                                                                      if([list objectForKey:@"error"] != nil){
                                                                          //Delegate For Fail
                                                                          NSLog(@"error:%@",[list objectForKey:@"error"]);
                                                                          return;
                                                                      }
                                                                  }                                                                  
                                                                  
                                                              } else {
                                                                  NSLog(@"error:%@",error);
                                                                  return;
                                                              }
                                                          }];
                                                          
                                                      } else {
                                                          NSLog(@"error:%@",error);
                                                          return;
                                                      }
                                                  }];

    } else {
        // Twitter account is not linked
        [[[UIAlertView alloc] initWithTitle:@"Twitter Not Linked"
                                    message:@"Please visit the shared settings to link your Twitter account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user
                         block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kFTActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
    [followActivity setObject:user forKey:kFTActivityToUserKey];
    [followActivity setObject:kFTActivityTypeFollow forKey:kFTActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    
    [[FTCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user
                       block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kFTActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
    [followActivity setObject:user forKey:kFTActivityToUserKey];
    [followActivity setObject:kFTActivityTypeFollow forKey:kFTActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[FTCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users
                        block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    for (PFUser *user in users) {
        [FTUtility followUserEventually:user block:completionBlock];
        [[FTCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user
                         block:(void (^)(NSError *error))completionBlock {
    
    //[FTUtility unfollowUserEventually:user block:completionBlock];
    //[[FTCache sharedCache] setFollowStatus:NO user:user];
    
    PFQuery *query = [PFQuery queryWithClassName:kFTActivityClassKey];
    [query whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kFTActivityToUserKey equalTo:user];
    [query whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
    
    [[FTCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUserEventually:(PFUser *)user {
    
    PFQuery *query = [PFQuery queryWithClassName:kFTActivityClassKey];
    [query whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kFTActivityToUserKey equalTo:user];
    [query whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    
    [[FTCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    
    PFQuery *query = [PFQuery queryWithClassName:kFTActivityClassKey];
    [query whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kFTActivityToUserKey containedIn:users];
    [query whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    
    for (PFUser *user in users) {
        [[FTCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnPost:(PFObject *)post
                          cachePolicy:(PFCachePolicy)cachePolicy {
    
    PFQuery *queryLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryLikes whereKey:kFTActivityPostKey equalTo:post];
    [queryLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryComments whereKey:kFTActivityPostKey equalTo:post];
    [queryComments whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kFTActivityFromUserKey];
    [query includeKey:kFTActivityPostKey];
    
    return query;
}

/*
+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryLikes whereKey:kFTActivityPostKey equalTo:photo];
    [queryLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryComments whereKey:kFTActivityPostKey equalTo:photo];
    [queryComments whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kFTActivityFromUserKey];
    [query includeKey:kFTActivityPostKey];
    
    return query;
}

+ (PFQuery *)queryForActivitiesOnVideo:(PFObject *)video cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryLikes whereKey:kFTActivityPostKey equalTo:video];
    [queryLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryComments whereKey:kFTActivityPostKey equalTo:video];
    [queryComments whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kFTActivityFromUserKey];
    [query includeKey:kFTActivityPostKey];
    
    return query;
}

+ (PFQuery *)queryForActivitiesOnGallery:(PFObject *)gallery cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryLikes whereKey:kFTActivityPostKey equalTo:gallery];
    [queryLikes whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryComments whereKey:kFTActivityPostKey equalTo:gallery];
    [queryComments whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kFTActivityFromUserKey];
    [query includeKey:kFTActivityPostKey];
    
    return query;
}
*/

#pragma mark Parse URL parameters

// A function for parsing URL parameters returned by the Feed Dialog.
+ (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark Clean Search String

+ (NSString *)getLowercaseStringWithoutSymbols:(NSString *)string {    
    return [[string stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING] lowercaseString];
}

#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];	    
}

#pragma mark Profile Hexagons

/*
+ (UIImageView *)getProfileHexagonWithFrame:(CGRect)rect {
    return [self getProfileHexagonWithX:rect.origin.x
                                      Y:rect.origin.y
                                  width:rect.size.width
                                 hegiht:rect.size.height];
}

+ (UIImageView *)getProfileHexagonWithX:(CGFloat)hexX
                                      Y:(CGFloat)hexY
                                  width:(CGFloat)hexW
                                 hegiht:(CGFloat)hexH {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    //imageView.frame = CGRectMake( 5.0f, 8.0f, 57.0f, 57.0f);
    imageView.frame = CGRectMake(hexX, hexY, hexW, hexH);
    imageView.backgroundColor = [UIColor redColor];
    
    CGRect rect = CGRectMake(hexX, hexY, hexW, hexH);
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = imageView.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
    CGFloat lcolumn = rect.size.width - sideWidth;
    CGFloat height = rect.size.height;
    CGFloat ty = (rect.size.height - height) / 2;
    CGFloat tmy = rect.size.height / 4;
    CGFloat bmy = rect.size.height - tmy;
    CGFloat by = rect.size.height;
    CGFloat rightmost = rect.size.width;
    
    [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
    
    [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
    
    hexagonMask.path = hexagonPath.CGPath;
    
    imageView.layer.mask = hexagonMask;
    [imageView.layer addSublayer:hexagonBorder];
    
    return imageView;
}
*/

#pragma mark Hashtags & Mentions

+ (NSArray *)extractHashtagsFromText:(NSString *)text {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0,text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [text substringWithRange:wordRange];
        
        [matchedResults addObject:word];
    }
    return matchedResults;
}

+ (NSArray *)extractMentionsFromText:(NSString *)text {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0,text.length)];
    
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [text substringWithRange:wordRange];
        
        [matchedResults addObject:word];
    }
    return matchedResults;
}

#pragma mark showHudMessage

+ (void)showHudMessage:(NSString *)message WithDuration:(NSTimeInterval)duration {
    //NSLog(@"%@::showHudMessage:WithDuration:",VIEWCONTROLLER_SETTINGS_DETAIL);    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    hud.labelText = message;
    [hud hide:YES afterDelay:duration];
}

@end

