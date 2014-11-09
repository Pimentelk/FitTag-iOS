//
//  UITableView+FTViewFriendsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFollowCell.h"

@interface FTViewFriendsViewController : UITableViewController <FTFollowCellDelegate>

@property (nonatomic, strong) PFUser *user;
- (void)queryForFollowers;
- (void)queryForFollowing;

@end
