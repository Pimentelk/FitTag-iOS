//
//  UIViewController+FTRewardsDetailView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailsHeaderView.h"
#import "FTRewardsDetailFooterView.h"

@interface FTRewardsDetailView : PFQueryTableViewController <FTRewardsDetailsHeaderViewDelegate,FTRewardsDetailsFooterViewDelegate>
@property (nonatomic, strong) PFObject *reward;
- (id)initWithReward:(PFObject *)aReward;
@end
