//
//  FTMapViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapViewController.h"
#import "FTCircleOverlay.h"
#import "FTAmbassadorGeoPointAnnotation.h"
#import "FTAmbassadorAnnotationView.h"
#import "FTBusinessAnnotationView.h"
#import "FTBusinessGeoPointAnnotation.h"
#import "FTMapScrollView.h"
#import "FTMapScrollViewItem.h"
#import "FTInterestsViewController.h"
#import "FTInterestViewFlowLayout.h"
#import "FTFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "FTSearchViewController.h"

// CONSTANTS

// QUERY SETTINGS
#define LOCATION_RADIUS 1000
#define QUERY_LIMIT 50

// Overlay Identifiers
#define CIRCLE_OVERLAY_IDENTIFIER @"Circle"
#define ANNOTATION_IDENTIFIER_BUSINESSES @"Businesses"
#define ANNOTATION_IDENTIFIER_AMBASSADOR @"Ambassador"

// Annotation Images
#define ANNOTATION_IMAGE_AMBASSADOR @"ambassador_annotation"
#define ANNOTATION_IMAGE_AMBASSADOR_WIDTH 24
#define ANNOTATION_IMAGE_AMBASSADOR_HEIGHT 37

#define ANNOTATION_IMAGE_BUSINESSES @""
#define ANNOTATION_IMAGE_BUSINESSES_WIDTH 35
#define ANNOTATION_IMAGE_BUSINESSES_HEIGHT 40

// ScrollView SETTINGS
#define SCROLLVIEW_HEIGHT 80

// ScrollViewItem SETTINGS
#define SCROLLVIEWITEM_HEIGHT SCROLLVIEW_HEIGHT

// KILOMETER SETTINGS
#define KILOMETER_TO_METERS 1000 // 1 mile
#define KILOMETER_95 KILOMETER_TO_METERS * 0.95
#define KILOMETER_90 KILOMETER_TO_METERS * 0.90
#define KILOMETER_85 KILOMETER_TO_METERS * 0.85
#define KILOMETER_75 KILOMETER_TO_METERS * 0.75
#define KILOMETER_50 KILOMETER_TO_METERS * 0.50
#define KILOMETER_25 KILOMETER_TO_METERS * 0.25
#define KILOMETER_15 KILOMETER_TO_METERS * 0.15
#define KILOMETER_10 KILOMETER_TO_METERS * 0.10
#define KILOMETER_05 KILOMETER_TO_METERS * 0.05

#define KILOMETER_TWO KILOMETER_TO_METERS * 2 // 2 miles
#define KILOMETER_THREE KILOMETER_TO_METERS * 3 // 3 miles
#define KILOMETER_FOUR KILOMETER_TO_METERS * 4 // 4 miles
#define KILOMETER_FIVE KILOMETER_TO_METERS * 5 // 5 miles

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1,
    PinAnnotationTypeTagGeoBusiness = 2,
    PinAnnotationTypeTagGeoAmbassador = 3
};

@interface FTMapViewController () {
    CLLocationManager *locationManager;
    FTMapScrollView *mapScrollView;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) FTSearchHeaderView *searchHeaderView;
@property (nonatomic, strong) FTCircleOverlay *targetOverlay;
@end

@implementation FTMapViewController
@synthesize searchHeaderView;
@synthesize geoPoint;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Init the MKMapView
    self.mapView = [[MKMapView alloc] initWithFrame: self.view.frame];
    [self.mapView setDelegate:self];
    [self.mapView setShowsBuildings:NO];
    [self.mapView setShowsPointsOfInterest:NO];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setHidden:NO];
    
    // Update the users location
    if (IS_OS_8_OR_LATER) {
        [[self locationManager] requestAlwaysAuthorization];
    }    
    [[self locationManager] startUpdatingLocation];
    
    // Set title
    [self.navigationItem setTitle:NAVIGATION_TITLE_SEARCH];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Set header view
    //searchHeaderView = [[FTSearchHeaderView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,35.0f)];
    //searchHeaderView.delegate = self;
    //searchHeaderView.searchbar.delegate = self;
    //self.tableView.tableHeaderView = searchHeaderView;
    
    // Set initial values
    //self.user       = [PFUser currentUser];
    //self.geoPoint   = self.user[kFTUserLocationKey];
    self.radius     = KILOMETER_FIVE;
    
    /*
    if (self.user[kFTUserLocationKey]) {
        
        // initial radius
        self.radius = MILES_25;
        
        // obtain the geopoint
        geoPoint = self.user[kFTUserLocationKey];
        
        // center our map view around this geopoint
        self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
        
        // add the annotation
        FTGeoPointAnnotation *annotation = [[FTGeoPointAnnotation alloc] initWithObject:self.user];
        [self.mapView addAnnotation:annotation];
    }
    
    // Dismiss keyboard gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [self configureOverlay];
    */
    
    mapScrollView = [[FTMapScrollView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height - SCROLLVIEW_HEIGHT -
                                                                      self.navigationController.toolbar.frame.size.height,
                                                                      self.mapView.frame.size.width, SCROLLVIEW_HEIGHT)];
    [mapScrollView setScrollEnabled:YES];
    //[mapScrollView setDelegate:self];
    [mapScrollView setUserInteractionEnabled:YES];
    [mapScrollView setDelaysContentTouches:YES];
    [mapScrollView setExclusiveTouch:YES];
    [mapScrollView setCanCancelContentTouches:YES];
    [mapScrollView setPagingEnabled: YES];
    [mapScrollView setAlwaysBounceVertical:NO];

    [self.mapView addSubview:mapScrollView];
    [self.mapView bringSubviewToFront:mapScrollView];
    
    [self isFirstTimeUser:[PFUser currentUser]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Navigation Bar

- (void)dismissKeyboard:(id)sender {
    if (searchHeaderView.searchbar != nil)
        [searchHeaderView.searchbar resignFirstResponder];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //NSLog(@"%@::mapView:viewForAnnotation:",VIEWCONTROLLER_MAP);
    static NSString *GeoPointBusinessAnnotationIdentifier = ANNOTATION_IDENTIFIER_BUSINESSES;
    static NSString *GeoPointAmbassadorAnnotationIdentifier = ANNOTATION_IDENTIFIER_AMBASSADOR;

    if ([annotation isKindOfClass:[FTAmbassadorGeoPointAnnotation class]]) {
        FTAmbassadorAnnotationView *annotationView = (FTAmbassadorAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAmbassadorAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[FTAmbassadorAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointAmbassadorAnnotationIdentifier];
            annotationView.image = [UIImage imageNamed:ANNOTATION_IMAGE_AMBASSADOR];
            annotationView.frame = CGRectMake(0, 0, ANNOTATION_IMAGE_AMBASSADOR_WIDTH, ANNOTATION_IMAGE_AMBASSADOR_HEIGHT);
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = NO;
            annotationView.draggable = NO;
        }
        return annotationView;
        
    } else if ([annotation isKindOfClass:[FTBusinessGeoPointAnnotation class]]) {
    
        FTBusinessAnnotationView *annotationView = (FTBusinessAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointBusinessAnnotationIdentifier];
        if (!annotationView) {            
            annotationView = [[FTBusinessAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointBusinessAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = NO;
            annotationView.draggable = NO;
        }
        return annotationView;
    }
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
           rendererForOverlay:(id<MKOverlay>)overlay {
    
    //NSLog(@"%@::mapView:rendererForOverlay:",VIEWCONTROLLER_MAP);
    static NSString *CircleOverlayIdentifier = CIRCLE_OVERLAY_IDENTIFIER;
    
    if ([overlay isKindOfClass:[FTCircleOverlay class]]) {
        FTCircleOverlay *circleOverlay = (FTCircleOverlay *)overlay;
        
        MKCircleRenderer *annotationView = (MKCircleRenderer *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:circleOverlay.coordinate
                                                             radius:circleOverlay.radius];
            annotationView = [[MKCircleRenderer alloc] initWithCircle:circle];
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

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {

    //NSLog(@"%@::mapView:annotationView:fromOldState:",VIEWCONTROLLER_MAP);
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery)
        return;
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        FTBusinessAnnotationView *businessQueryAnnotation = (FTBusinessAnnotationView *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:businessQueryAnnotation.coordinate.latitude
                                                   longitude:businessQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}

#pragma mark - SearchViewController

- (void)setInitialLocation:(CLLocation *)aLocation {
    //NSLog(@"%@::setInitialLocation: %@",VIEWCONTROLLER_MAP,aLocation);
    self.location = aLocation;
    [self configureOverlay];
}

#pragma mark - ()

- (BOOL) isFirstTimeUser:(PFUser *)user {
    //NSLog(@"%@::isFirstTimeUser:",VIEWCONTROLLER_CONFIG);
    // Check if the user has logged in before
    if (![user objectForKey:kFTUserLastLoginKey]) {
        FTInterestViewFlowLayout *layoutFlow = [[FTInterestViewFlowLayout alloc] init];
        [layoutFlow setItemSize:CGSizeMake(159.5,42)];
        [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layoutFlow setMinimumInteritemSpacing:0];
        [layoutFlow setMinimumLineSpacing:0];
        [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
        [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
        
        // Show the interests
        FTInterestsViewController *interestsViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:layoutFlow];
        UINavigationController *navController = [[UINavigationController alloc] init];
        [navController setViewControllers:@[interestsViewController] animated:NO];
        [self presentViewController:navController animated:YES completion: ^(){
            [user setValue:[NSDate date] forKey:kFTUserLastLoginKey];
            if (user) {
                [user saveEventually];
            }
            [self.tabBarController setSelectedIndex:1];
        }];
        NSLog(FIRSTTIME_USER);
        return YES;
    }
    
    NSLog(RETURNING_USER);
    return NO;
}

- (void)configureOverlay {
    //NSLog(@"%@::configureOverlay",VIEWCONTROLLER_MAP);
    /*
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        FTCircleOverlay *overlay = [[FTCircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        
        FTGeoQueryAnnotation *annotation = [[FTGeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addAnnotation:annotation];
        
        //[self updateLocations];
    }*/
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    //self.location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    //NSLog(@"self.location: %@",self.location);
    
    //self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
    
    // center our map view around this geopoint
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.0225f, 0.0225f));

    // Animate zoom into geopoint center
    [self.mapView setRegion:region animated:NO];
    [self.view addSubview: self.mapView];
    [self updateLocations];
    
    // Set marker on current location
    //FTGeoQueryAnnotation *annotation = [[FTGeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    //[self.mapView addAnnotation:annotation];
    
    /*
    // Add radius on current user location
    FTCircleOverlay *overlay = [[FTCircleOverlay alloc] initWithCoordinate:self.location.coordinate
                                                                    radius:self.radius];
    [self.mapView addOverlay:overlay];
    */
    
}

- (void)updateLocations {
    //NSLog(@"%@::updateLocations:",VIEWCONTROLLER_MAP);
    CGFloat miles = self.radius/1000.0f;
    
    for (UIView *mapScrollViewSubView in mapScrollView.subviews) {
        [mapScrollViewSubView removeFromSuperview];
    }
    
    PFGeoPoint *nearGeoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                                      longitude:self.location.coordinate.longitude];
    
    NSMutableArray *mapItems = [[NSMutableArray alloc] init];
    
    PFQuery *queryBusinessUsers = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryBusinessUsers whereKey:kFTUserTypeKey equalTo:kFTUserTypeBusiness];
    [queryBusinessUsers whereKey:kFTUserLocationKey nearGeoPoint:nearGeoPoint withinMiles:miles];
    [queryBusinessUsers setLimit:QUERY_LIMIT];
    [queryBusinessUsers orderByAscending:kFTUserLastnameKey];
    [queryBusinessUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Business Locations: %@", objects);
            for (PFObject *object in objects) {
                [mapItems addObject:object];
                
                //[mapScrollView addSubview: [[FTMapScrollViewItem alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, 120)]];
                
                FTBusinessGeoPointAnnotation *businessGeoPointAnnotation = [[FTBusinessGeoPointAnnotation alloc] initWithObject:object];
                [self.mapView addAnnotation:businessGeoPointAnnotation];
            }
            
            int i = 0;
            for (PFObject *object in mapItems) {
                PFFile *file = [object objectForKey:kFTUserProfilePicSmallKey];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        CGFloat xOrigin = i * self.mapView.frame.size.width;
                        
                        FTMapScrollViewItem *viewItem = [[FTMapScrollViewItem alloc] initWithFrame:CGRectMake(xOrigin, 0, self.mapView.frame.size.width, SCROLLVIEWITEM_HEIGHT)];
                        
                        UIImage *image = [UIImage imageWithData:data]; // Image
                        NSString *title = [object objectForKey:kFTUserCompanyNameKey]; // CompanyName
                        PFGeoPoint *userGeoPoint = [object objectForKey:kFTUserLocationKey]; // Location GeoPoint
                        
                        [viewItem.itemImageView setImage:image];
                        [viewItem.titleLabel setText:[title uppercaseString]];
                        
                        /* Convert Location */
                        if (userGeoPoint) {
                            CLLocation *location = [[CLLocation alloc] initWithLatitude:userGeoPoint.latitude longitude:userGeoPoint.longitude];
                            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                            [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                                if (!error) {
                                    for (CLPlacemark *placemark in placemarks) {
                                        NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                                        if (postLocation) {
                                            [viewItem.locationLabel setText:postLocation];
                                        }
                                    }
                                } else {
                                    NSLog(@"ERROR: %@",error);
                                }
                            }];
                        } else {
                            [viewItem.locationLabel setText:EMPTY_STRING];
                        }
                        
                        [mapScrollView addSubview:viewItem];
                    }
                }];
                i++;
            }
            
            PFQuery *queryAmbassadorUsers = [PFQuery queryWithClassName:kFTUserClassKey];
            [queryAmbassadorUsers whereKey:kFTUserTypeKey equalTo:kFTUserTypeAmbassador];
            [queryAmbassadorUsers whereKey:kFTUserLocationKey nearGeoPoint:nearGeoPoint withinMiles:miles];
            
            PFQuery *queryAmbassadorPosts = [PFQuery queryWithClassName:kFTPostClassKey];
            [queryAmbassadorPosts whereKey:kFTPostUserKey matchesQuery:queryAmbassadorUsers];
            [queryAmbassadorPosts whereKey:kFTPostLocationKey nearGeoPoint:nearGeoPoint withinMiles:miles];
            [queryAmbassadorPosts setLimit:QUERY_LIMIT];
            [queryAmbassadorPosts orderByAscending:kFTPostLocationKey];
            [queryAmbassadorPosts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    //NSLog(@"Ambassador Posts: %@", objects);
                    for (PFObject *object in objects) {
                        [mapItems addObject:object];
                        //[mapScrollView addSubview: [[FTMapScrollViewItem alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, 120)]];
                        
                        
                        FTAmbassadorGeoPointAnnotation *ambassadorGeoPointAnnotation = [[FTAmbassadorGeoPointAnnotation alloc] initWithObject:object];
                        [self.mapView addAnnotation:ambassadorGeoPointAnnotation];
                    }
                    
                    /*
                    int i = 0;
                    for (PFObject *object in mapItems) {
                        PFFile *file = [object objectForKey:kFTPostImageKey];
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageInGalleryAction:)];
                                singleTap.numberOfTapsRequired = 1;
                                
                                CGFloat xOrigin = i * 320;
                                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 320.0f, 320.0f)];
                                [imageView setBackgroundColor:[UIColor clearColor]];
                                UIImage *image = [UIImage imageWithData:data];
                                [imageView setImage:image];
                                [imageView setClipsToBounds:YES];
                                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                                [imageView setUserInteractionEnabled:YES];
                                [imageView addGestureRecognizer:singleTap];
                                [mapScrollView addSubview:imageView];
                            }
                        }];
                        i++;
                    }
                    */
                }
            }];
        }
    }];
}

- (void)didTapImageInGalleryAction:(UIButton *)button {
    
}

#pragma mark - FT

/*
-(void)searchHeaderView:(FTSearchHeaderView *)searchHeaderView didChangeFrameSize:(CGRect)rect{
    [self.searchHeaderView setFrame:rect];
    self.tableView.tableHeaderView = self.searchHeaderView;
}
*/

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (trimmedComment.length != 0) {
        
    }
    
    [textField setText:EMPTY_STRING];
    return [textField resignFirstResponder];
}

#pragma mark - CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
    //NSLog(@"%@::locationManager",VIEWCONTROLLER_MAP);
    if (locationManager != nil) {
        return locationManager;
    }
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@::didFailWithError: %@", VIEWCONTROLLER_MAP, error);
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Failed to Get Your Location"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"%@::locationManager:didUpdateLocations:",VIEWCONTROLLER_MAP);
    [locationManager stopUpdatingLocation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        CLLocation *location = [locations lastObject];
        geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                          longitude:location.coordinate.longitude];
        [user setValue:geoPoint forKey:kFTUserLocationKey];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //NSLog(@"%@::locationManager:didUpdateLocations: - User location updated successfully.",VIEWCONTROLLER_MAP);
                [self setInitialLocation:location];
            }
        }];
    }
}

@end
