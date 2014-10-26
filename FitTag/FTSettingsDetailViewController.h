//
//  FTAccountHeaderView+FTSettingsDetailViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSocialCell.h"
#import "FTCamViewController.h"

@interface FTSettingsDetailViewController : UIViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,FTSocialCellDelegate,FTCamViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@end
