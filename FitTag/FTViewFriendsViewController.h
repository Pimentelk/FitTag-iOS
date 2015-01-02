//
//  UITableView+FTViewFriendsViewController.h
//  FitTag
//
//  For viewing friends who are currently following or being followed by specified user
//
//  Created by Kevin Pimentel on 11/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFollowCell.h"

@interface FTViewFriendsViewController : UITableViewController <FTFollowCellDelegate>

@property (nonatomic, strong) PFUser *user;
- (void)queryForFollowers;
- (void)queryForFollowing;
- (void)queryForLickersOf:(PFObject *)object;
@end
