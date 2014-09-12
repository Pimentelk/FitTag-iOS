//
//  FTMapViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FTMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) PFObject *user;
@property (nonatomic,strong) MKMapView *mapView;

@end
