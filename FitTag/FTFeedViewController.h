//
//  FeedViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTToolBar.h"
#import "FTPhotoTimelineViewController.h"

@interface FTFeedViewController : PFQueryTableViewController <FTToolBarDelegate>
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
