//
//  FTPlaceProfileViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 2/3/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileHeaderView.h"
#import "FTTimelineViewController.h"

@interface FTPlaceProfileViewController : FTTimelineViewController

@property (nonatomic, strong) PFUser *contact;
@property (nonatomic, strong) PFObject *place;

@end
