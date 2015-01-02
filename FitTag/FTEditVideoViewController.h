//
//  FTEditPhotoViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"
#import <CoreLocation/CoreLocation.h>
#import "FTSuggestionTableView.h"
#import "FTPlacesViewController.h"

@interface FTEditVideoViewController : UIViewController <UITextViewDelegate,
                                                         UITextFieldDelegate,
                                                         UIScrollViewDelegate,
                                                         FTPostDetailsFooterViewDelegate,
                                                         CLLocationManagerDelegate,
                                                         FTSuggestionTableViewDelegate,
                                                         FTPlacesViewControllerDelegate,
                                                         UIAlertViewDelegate>

@property (nonatomic,readonly) UIButton *playButton;

- (id)initWithVideo:(NSData *)aVideo;

@end
