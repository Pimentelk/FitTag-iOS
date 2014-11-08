//
//  FTFeedViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTTimelineViewController.h"

@interface FTFeedViewController : FTTimelineViewController
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
