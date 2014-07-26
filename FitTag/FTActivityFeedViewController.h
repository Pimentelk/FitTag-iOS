//
//  NotificationsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTActivityCell.h"

@interface FTActivityFeedViewController : PFQueryTableViewController <FTActivityCellDelegate>
+ (NSString *)stringForActivityType:(NSString *)activityType;
@end
