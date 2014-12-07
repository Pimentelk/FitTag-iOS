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
#import <MessageUI/MessageUI.h>

@interface FTTimelineViewController : PFQueryTableViewController <FTPhotoCellDelegate,
                                                                  FTVideoCellDelegate,
                                                                  FTGalleryCellDelegate,
                                                                  FTPostHeaderViewDelegate,
                                                                  UIActionSheetDelegate,
                                                                  UIAlertViewDelegate,
                                                                  UIGestureRecognizerDelegate,
                                                                  MFMailComposeViewControllerDelegate>

- (FTPostHeaderView *)dequeueReusableSectionHeaderView;

@end
