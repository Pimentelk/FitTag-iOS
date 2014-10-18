//
//  UITableView+FTProfileTimelineViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTUserProfileHeaderView.h"

@interface FTUserProfileCollectionViewController : UICollectionViewController <FTUserProfileHeaderViewDelegate>
@property (nonatomic, strong) PFUser *user;
@end
