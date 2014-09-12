//
//  FTMapViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapViewController.h"
#import "FTGeoPointAnnotation.h"

@interface FTMapViewController ()

@end

@implementation FTMapViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // Set title
    [self.navigationItem setTitle: @"SEARCH"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set back indicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
        
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Init the MKMapView
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.mapView];
    
    // Set current user
    self.user = [PFUser currentUser];
    
    if (self.user[kFTUserLocationKey]) {
        // obtain the geopoint
        PFGeoPoint *geoPoint = self.user[kFTUserLocationKey];
        
        // center our map view around this geopoint
        self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
        
        // add the annotation
        FTGeoPointAnnotation *annotation = [[FTGeoPointAnnotation alloc] initWithObject:self.user];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)returnHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPin";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.canShowCallout = NO;
        annotationView.draggable = NO;
        annotationView.animatesDrop = YES;
    }
    
    return annotationView;
}

@end
