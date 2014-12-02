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
#import "FTToolbar.h"
#import "FTMapScrollViewItem.h"
#import "FTFollowFriendsViewController.h"
#import "FTLocationManager.h"
#import "FTAmbassadorAnnotationView.h"
#import "FTBusinessAnnotationView.h"

@interface FTMapViewController : UIViewController <FTSearchHeaderViewDelegate,
                                                   FTMapScrollViewItemDelegate,
                                                   MKMapViewDelegate,
                                                   UIScrollViewDelegate,
                                                   UISearchBarDelegate,
                                                   UITextFieldDelegate,
                                                   FTAmbassadorAnnotationViewDelegate,
                                                   FTBusinessAnnotationViewDelegate,
                                                   FTLocationManagerDelegate>
@property (nonatomic, strong) PFObject *user;
@property (nonatomic, strong) MKMapView *mapView;

- (void)setInitialLocation:(CLLocation *)aLocation;

@end
