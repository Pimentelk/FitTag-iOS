//
//  FTPhotoTimelineViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoCell.h"
#import "FTVideoCell.h"

@interface FTPhotoTimelineViewController : PFQueryTableViewController <FTPhotoCellDelegate,FTVideoCellDelegate,UIActionSheetDelegate>
- (FTPhotoCell *)dequeueReusableSectionHeaderView;
@end
