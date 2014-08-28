//
//  FTPhotoTimelineViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoCell.h"

@interface FTPhotoTimelineViewController : PFQueryTableViewController <FTPhotoCellDelegate, UIActionSheetDelegate>

- (FTPhotoCell *)dequeueReusableSectionHeaderView;

@end
