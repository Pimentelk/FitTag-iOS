//
//  FTAddPlaceViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 12/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLocationManager.h"
#import "FTSuggestionTableView.h"

@protocol FTAddPlaceViewControllerDelegate;

@interface FTAddPlaceViewController : UIViewController <UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate,FTSuggestionTableViewDelegate>
@property (nonatomic, weak) id<FTAddPlaceViewControllerDelegate> delegate;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@end

@protocol FTAddPlaceViewControllerDelegate <NSObject>
- (void)addPlaceViewController:(FTAddPlaceViewController *)addPlaceViewController didAddNewplace:(PFObject *)place location:(PFObject *)location;
@end