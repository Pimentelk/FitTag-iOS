//
//  FTPlacesTableViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 12/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTAddPlaceViewController.h"

@protocol FTPlacesViewControllerDelegate;

@interface FTPlacesViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,FTAddPlaceViewControllerDelegate>

@property (nonatomic, strong) UISearchBar *placesSearchbar;

@property (nonatomic, weak) id<FTPlacesViewControllerDelegate> delegate;

@property (nonatomic, strong) PFGeoPoint *geoPoint;

@end

@protocol FTPlacesViewControllerDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a place is selected
 @param place the place that was selected
 */
- (void)placesViewController:(FTPlacesViewController *)placesViewController didTapSelectPlace:(PFObject *)place;

/*!
 Sent to the delegate when cancel button is pressed
 @param cancel the button that was pressed
 */
- (void)placesViewController:(FTPlacesViewController *)placesViewController didTapCancelButton:(UIButton *)button;

/*!
 Sent to the delegate when the add place button is tapped
 @param button the button that was tapped
 */
- (void)placesViewController:(FTPlacesViewController *)placesViewController didTapAddNewPlaceButton:(UIButton *)button;

@end
