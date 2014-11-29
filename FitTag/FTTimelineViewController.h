//
//  FTTimelineViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoCell.h"
#import "FTVideoCell.h"
#import "FTGalleryCell.h"
#import "FTPostHeaderView.h"

@interface FTTimelineViewController : PFQueryTableViewController <FTPhotoCellDelegate,
                                                                  FTVideoCellDelegate,
                                                                  FTGalleryCellDelegate,
                                                                  FTPostHeaderViewDelegate,
                                                                  UIActionSheetDelegate,
                                                                  UIGestureRecognizerDelegate>

- (FTPostHeaderView *)dequeueReusableSectionHeaderView;

@end
