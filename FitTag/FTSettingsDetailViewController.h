//
//  FTAccountHeaderView+FTSettingsDetailViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSocialCell.h"

@interface FTSettingsDetailViewController : UIViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,FTSocialCellDelegate>

@property (strong, nonatomic) id detailItem;
@end
