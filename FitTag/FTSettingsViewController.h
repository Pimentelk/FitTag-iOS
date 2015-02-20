//
//  FTSettingsActionSheetDelegate.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsDetailViewController.h"
#import "FTInterestsViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTInterestViewFlowLayout.h"
#import <MessageUI/MessageUI.h>

@protocol FTSettingsViewControllerDelegate;

@interface FTSettingsViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,FTInterestsViewControllerDelegate>

@property (nonatomic, weak) id<FTSettingsViewControllerDelegate> delegate;

@end

@protocol FTSettingsViewControllerDelegate <NSObject>

/*
 * @param setting that was pressed
 * Called when setting has been selected
 */
- (void)settingsViewController:(FTSettingsViewController *)settingsViewController
                 didTapSetting:(NSString *)setting;

/*
 * @param sender the pressed button
 * Called when detail view is dismissed
 */
- (void)settingsViewController:(FTSettingsViewController *)settingsViewController
                viewWillAppear:(BOOL)visible;

@end