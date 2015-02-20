//
//  FTSidePanelViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 1/30/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

@protocol FTSidePanelViewControllerDelegate;
@interface FTSidePanelViewController : UITableViewController

@property (nonatomic, weak) id<FTSidePanelViewControllerDelegate> delegate;

@end

@protocol FTSidePanelViewControllerDelegate <NSObject>

- (void)sidePanelViewController:(FTSidePanelViewController *)sidePanelViewController
         didTapMenuButtonAction:(UIBarButtonItem *)button;

@end
