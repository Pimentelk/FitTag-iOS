//
//  FTMapViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapViewController.h"
#import "FTGeoPointAnnotation.h"
#import "FTGeoQueryAnnotation.h"
#import "FTCircleOverlay.h"

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface FTMapViewController ()
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) FTSearchHeaderView *searchHeaderView;
@property (nonatomic, strong) FTCircleOverlay *targetOverlay;
@end

@implementation FTMapViewController
@synthesize searchHeaderView;
@synthesize geoPoint;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // Update the users location
    //[[self locationManager] startUpdatingLocation];
    
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
    
    // Set header view
    searchHeaderView = [[FTSearchHeaderView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,35.0f)];
    searchHeaderView.delegate = self;
    searchHeaderView.searchbar.delegate = self;
    self.tableView.tableHeaderView = searchHeaderView;
    
    // Set current user
    self.user = [PFUser currentUser];
    
    if (self.user[kFTUserLocationKey]) {
        // obtain the geopoint
        geoPoint = self.user[kFTUserLocationKey];
        
        // center our map view around this geopoint
        self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
        
        // add the annotation
        FTGeoPointAnnotation *annotation = [[FTGeoPointAnnotation alloc] initWithObject:self.user];
        [self.mapView addAnnotation:annotation];
    }

    // Dismiss keyboard gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [self configureOverlay];
}

-(void)dismissKeyboard:(id)sender {
    if (searchHeaderView.searchbar != nil)
        [searchHeaderView.searchbar resignFirstResponder];
}

- (void)returnHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[FTGeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = NO;
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[FTGeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    static NSString *CircleOverlayIdentifier = @"Circle";
    
    if ([overlay isKindOfClass:[FTCircleOverlay class]]) {
        FTCircleOverlay *circleOverlay = (FTCircleOverlay *)overlay;
        
        MKCircleView *annotationView =
        (MKCircleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle
                                circleWithCenterCoordinate:circleOverlay.coordinate
                                radius:circleOverlay.radius];
            annotationView = [[MKCircleView alloc] initWithCircle:circle];
        }
        
        if (overlay == self.targetOverlay) {
            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationView.strokeColor = [UIColor redColor];
            annotationView.lineWidth = 1.0f;
        } else {
            annotationView.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
            annotationView.strokeColor = [UIColor purpleColor];
            annotationView.lineWidth = 2.0f;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        FTGeoQueryAnnotation *geoQueryAnnotation = (FTGeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}

#pragma mark - SearchViewController

- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
    self.radius = 1000;
}

#pragma mark - ()

- (void)configureOverlay {
    NSLog(@"configureOverlay: %@",self.location);
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        FTCircleOverlay *overlay = [[FTCircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        
        FTGeoQueryAnnotation *annotation = [[FTGeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addAnnotation:annotation];
        
        [self updateLocations];
    }
}

- (void)updateLocations {
    CGFloat miles = 50.0f;
    PFQuery *query = [PFQuery queryWithClassName:kFTPostClassKey];
    [query setLimit:1000];
    [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude] withinMiles:miles];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"query: %@",objects);
            for (PFObject *object in objects) {
                FTGeoPointAnnotation *geoPointAnnotation = [[FTGeoPointAnnotation alloc] initWithObject:object];
                [self.mapView addAnnotation:geoPointAnnotation];
            }
        }
    }];
}

#pragma mark - FT

-(void)searchHeaderView:(FTSearchHeaderView *)searchHeaderView didChangeFrameSize:(CGRect)rect{
    [self.searchHeaderView setFrame:rect];
    self.tableView.tableHeaderView = self.searchHeaderView;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (trimmedComment.length != 0) {
        
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}
@end
