//
//  FTSettingsActionSheetDelegate.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsDetailViewController.h"
#import "FTInterestsViewController.h"
#import "FTFindFriendsViewController.h"
#import "FTInterestViewFlowLayout.h"
#import <MessageUI/MessageUI.h>

@interface FTSettingsViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,FTInterestsViewControllerDelegate>

@property (strong, nonatomic) FTSettingsDetailViewController *settingsDetailViewController;
@property (strong, nonatomic) FTFindFriendsViewController *findFriendsViewController;
@property (strong, nonatomic) FTInterestsViewController *interestsViewController;
@end