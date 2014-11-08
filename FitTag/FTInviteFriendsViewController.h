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
    FTFollowUserQueryTypeAmbassador = 1 << 2,
    FTFollowUserQueryTypeBusiness = 1 << 3,
    FTFollowUserQueryTypeUser = 1 << 4,
    FTFollowUserQueryTypeTagger = FTFollowUserQueryTypeAmbassador | FTFollowUserQueryTypeBusiness | FTFollowUserQueryTypeUser,
    FTFollowUserQueryTypeDefault = FTFollowUserQueryTypeNear
} FTFollowUserQueryType;

#import "FTFollowCell.h"
#import "FTInviteTableHeaderView.h"

@interface FTInviteFriendsViewController : UITableViewController <FTFollowCellDelegate,FTInviteTableHeaderViewDelegate>
@property (nonatomic, assign) FTFollowUserQueryType followUserQueryType;
@property (nonatomic, strong) NSString *searchString;
@end
