//
//  FeedViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FitTagToolBar.h"

@interface FeedViewController : PFQueryTableViewController <FitTagToolBarDelegate>
@property (nonatomic,retain) NSMutableArray *usersBeingFollowed;
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
