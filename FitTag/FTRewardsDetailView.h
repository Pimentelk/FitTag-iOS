//
//  UIViewController+FTRewardsDetailView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailHeaderView.h"
#import "FTRewardsDetailFooterView.h"

typedef enum {
    FTRewardTypeNone = 0,
    FTRewardTypeActive = 1 << 0,
    FTRewardTypeUsed = 1 << 1,
    FTRewardTypeExpired = 1 << 2,
    FTRewardTypeDefault = FTRewardTypeActive
} FTRewardType;

@interface FTRewardsDetailView : PFQueryTableViewController <FTRewardsDetailHeaderViewDelegate,FTRewardsDetailsFooterViewDelegate>
@property (nonatomic, strong) PFObject *reward;
@property (nonatomic, assign) FTRewardType rewardType;
- (id)initWithReward:(PFObject *)aReward;
@end
