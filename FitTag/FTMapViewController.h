//
//  FTMapViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchHeaderView.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FTMapViewController : UITableViewController <MKMapViewDelegate,FTSearchHeaderViewDelegate,UISearchBarDelegate,UITextFieldDelegate>
@property (nonatomic, strong) PFObject *user;
@property (nonatomic,strong) MKMapView *mapView;

- (void)setInitialLocation:(CLLocation *)aLocation;

@end
