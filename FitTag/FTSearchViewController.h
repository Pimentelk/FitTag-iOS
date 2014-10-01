//
//  FTSearchResultsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchCell.h"
#import "FTSearchHeaderView.h"
#import <CoreLocation/CoreLocation.h>

@interface FTSearchViewController : PFQueryTableViewController <FTSearchHeaderViewDelegate,FTSearchCellDelegate,UIActionSheetDelegate,
                                                                CLLocationManagerDelegate,UITextFieldDelegate,UISearchBarDelegate>
@end
