//
//  FTAccountHeaderView+FTSettingsDetailViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSwitchCell.h"
#import "FTCamViewController.h"
#import "FTCropImageViewController.h"

@interface FTSettingsDetailViewController : UIViewController <UITextViewDelegate,UITableViewDataSource,UITextFieldDelegate,
                                                              UITableViewDelegate,FTSwitchCellDelegate,
                                                              FTCamViewControllerDelegate,FTCropImageViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@end
