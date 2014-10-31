//
//  FTInviteFriendsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTFollowUserQueryTypeNone = 0,
    FTFollowUserQueryTypeNear = 1 << 0,
    FTFollowUserQueryTypeInterest = 1 << 1,
    FTFollowUserQueryTypeDefault = FTFollowUserQueryTypeNear
} FTFollowUserQueryType;

#import "FTFollowCell.h"
#import "FTInviteTableHeaderView.h"

@interface FTInviteFriendsViewController : UITableViewController <FTFollowCellDelegate,FTInviteTableHeaderViewDelegate>

@end
