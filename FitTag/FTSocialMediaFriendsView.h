//
//  FTSocialMediaFriendsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//
/**
 * FTSocialMediaFriendsView is a view, used to display all users who are members of FitTag and
   also friends of the current user on facebok.
 * Header view contains a string.
 * Tableview is added to the uiview to display the matching users.
 * FTFollowCell is the cell used in the table to follow/unfollow users that matched.
 **/

#import "FTFollowCell.h"

@protocol FTSocialMediaFriendsViewDelegate;
@interface FTSocialMediaFriendsView : UIView <UITableViewDataSource,UITableViewDelegate,FTFollowCellDelegate>

@property (nonatomic, weak) id<FTSocialMediaFriendsViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol FTSocialMediaFriendsViewDelegate <NSObject>
@optional

- (void) socialMediaFriendsView:(FTSocialMediaFriendsView *)socialMediaFriendsView didTapProfileImage:(UIButton *)button user:(PFUser *)aUser;

@end
