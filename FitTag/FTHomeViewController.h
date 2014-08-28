//
//  FTHomeViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTToolBar.h"
#import "FTPhotoTimelineViewController.h"

@interface FTHomeViewController : FTPhotoTimelineViewController <FTToolBarDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@end
