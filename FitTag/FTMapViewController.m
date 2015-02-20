//
//  FTMapViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapViewController.h"
#import "FTCircleOverlay.h"
#import "FTPlaceGeoPointAnnotation.h"
#import "FTAmbassadorGeoPointAnnotation.h"
#import "FTMapScrollView.h"
#import "FTSearchViewController.h"
#import "FTPlaceProfileViewController.h"
#import "FTNavigationController.h"
#import "FTPostDetailsViewController.h"
#import "FTUserProfileViewController.h"

// CONSTANTS

// QUERY SETTINGS
#define LOCATION_RADIUS 1000
#define QUERY_LIMIT 60

// Overlay Identifiers
#define CIRCLE_OVERLAY_IDENTIFIER @"Circle"
//#define ANNOTATION_IDENTIFIER_BUSINESSES @"Businesses"
//#define ANNOTATION_IDENTIFIER_AMBASSADOR @"Ambassador"
#define ANNOTATION_IDENTIFIER_PLACE @"Place"

// Annotation Images
#define ANNOTATION_IMAGE_AMBASSADOR @"ambassador_annotation"
#define ANNOTATION_IMAGE_AMBASSADOR_WIDTH 24
#define ANNOTATION_IMAGE_AMBASSADOR_HEIGHT 37

#define ANNOTATION_IMAGE_BUSINESSES @""
#define ANNOTATION_IMAGE_BUSINESSES_WIDTH 35
#define ANNOTATION_IMAGE_BUSINESSES_HEIGHT 40

// ScrollView SETTINGS
#define SCROLLVIEW_HEIGHT 80

// Animation Duration
#define ANIMATION_DURATION 0.5

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
    UIScrollView *scrollView;
    NSMutableArray *mapItems;
    FTSearchQueryType searchQueryType;
    BOOL isUserFilterSelected;
    int position;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) FTCircleOverlay *targetOverlay;
@property (nonatomic, strong) FTLocationManager *locationManager;
@property (nonatomic, strong) UIImageView *errorLocationImage;
@end

@implementation FTMapViewController
@synthesize geoPoint;
@synthesize locationManager;
@synthesize errorLocationImage;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frameRect = self.view.frame;
    
    // init position
    position = 0;
    
    // init arrays
    mapItems = [[NSMutableArray alloc] init];
    
    // init the MKMapView
    self.mapView = [[MKMapView alloc] initWithFrame:frameRect];
    [self.mapView setDelegate:self];
    [self.mapView setShowsBuildings:NO];
    [self.mapView setShowsPointsOfInterest:NO];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setHidden:NO];
    [self.mapView setShowsUserLocation:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouldDismissViewGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shouldDismissViewGesture:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    
    UIImage *noLocationImage = [UIImage imageNamed:@"no_location"];
    errorLocationImage = [[UIImageView alloc] initWithImage:noLocationImage];
    [errorLocationImage setUserInteractionEnabled:YES];
    [errorLocationImage setFrame:CGRectMake(0, 0, 263, 298)];
    [errorLocationImage setCenter:CGPointMake(frameRect.size.width/2, frameRect.size.height/2)];
    [errorLocationImage setGestureRecognizers:@[ tapGesture, swipeGesture ]];
    
    // manage user location
    locationManager = [[FTLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    // Set radius
    self.radius = KILOMETER_FIVE;
    
    // config Scrollview
    CGFloat offsetY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    CGFloat scrollViewY = self.mapView.frame.size.height - SCROLLVIEW_HEIGHT - offsetY;
    
    CGFloat scrollViewWidth = self.mapView.frame.size.width;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollViewY, scrollViewWidth, SCROLLVIEW_HEIGHT)];
    [scrollView setScrollEnabled:YES];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setUserInteractionEnabled:YES];
    [scrollView setDelaysContentTouches:YES];
    [scrollView setExclusiveTouch:YES];
    [scrollView setCanCancelContentTouches:YES];
    [scrollView setPagingEnabled: YES];
    [scrollView setAlwaysBounceVertical:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [locationManager requestLocationAuthorization];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.skipAnimation == YES) {
        return;
    }
    
    if (geoPoint) {
        // center our map view around this geopoint
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude,geoPoint.longitude),MKCoordinateSpanMake(0.0025f,0.0025f));
        
        // Animate zoom into geopoint center
        [self.mapView setRegion:region animated:YES];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *GeoPointPlaceAnnotationIdentifier = ANNOTATION_IDENTIFIER_PLACE;
    
    if ([annotation isKindOfClass:[FTPlaceGeoPointAnnotation class]]) {
        
        FTBusinessAnnotationView *annotationView = (FTBusinessAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointPlaceAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[FTBusinessAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointPlaceAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = NO;
            annotationView.draggable = NO;
            annotationView.delegate = self;
        }
        
        FTPlaceGeoPointAnnotation *placeGeoPointAnnotation = annotation;
        annotationView.file = [placeGeoPointAnnotation file];
        annotationView.coordinate = [placeGeoPointAnnotation coordinate];
        
        for (int i = 0; i < mapItems.count; i++) {
            
            PFObject *object = [mapItems objectAtIndex:i];
            NSString *mapItemId = object.objectId;
            
            if ([mapItemId isEqualToString:[placeGeoPointAnnotation objectId]]) {
                annotationView.position = i;
            }
        }
        
        return annotationView;
    }
    
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
    
    //NSLog(@"%@::mapView:rendererForOverlay:",VIEWCONTROLLER_MAP);
    static NSString *CircleOverlayIdentifier = CIRCLE_OVERLAY_IDENTIFIER;
    
    if ([overlay isKindOfClass:[FTCircleOverlay class]]) {
        
        FTCircleOverlay *circleOverlay = (FTCircleOverlay *)overlay;
        
        MKCircleRenderer *annotationView = (MKCircleRenderer *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:circleOverlay.coordinate radius:circleOverlay.radius];
            annotationView = [[MKCircleRenderer alloc] initWithCircle:circle];
        }
        
        if (overlay == self.targetOverlay) {
            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationView.strokeColor = FT_RED;
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

#pragma mark - SearchViewController

- (void)setInitialLocationObject:(PFObject *)object {
    
    if ([object objectForKey:kFTPostPlaceKey]) {
        
        PFObject *place = [object objectForKey:kFTPostPlaceKey];
        [place fetchIfNeededInBackgroundWithBlock:^(PFObject *place, NSError *error) {
            if (!error) {
                
                geoPoint = [place objectForKey:kFTPlaceLocationKey];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                
                if (location) {
                    self.location = location;
                    [self configurePostOverlay:object];
                }
            }
        }];
    }
}

- (void)setInitialLocation:(CLLocation *)aLocation {
    //NSLog(@"%@::setInitialLocation: %@",VIEWCONTROLLER_MAP,aLocation);
    if (!self.location) {
        self.location = aLocation;
        [self configureOverlay];
    }
}

#pragma mark

- (void)didTapPopSearchButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shouldDismissViewGesture:(id)sender {

}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setMapCenterWithPoint:(PFGeoPoint *)centerPoint {
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerPoint.latitude,centerPoint.longitude),
                                                 MKCoordinateSpanMake(0.0025f, 0.0025f));
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configurePostOverlay:(PFObject *)object {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.view addSubview: self.mapView];
    
    // center our map view around this geopoint
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.location.coordinate.latitude,
                                                                                  self.location.coordinate.longitude),
                                                       MKCoordinateSpanMake(0.0025f, 0.0025f));
    
    // Animate zoom into geopoint center
    [self.mapView setRegion:region animated:NO];
    
    FTAmbassadorGeoPointAnnotation *annotation = [[FTAmbassadorGeoPointAnnotation alloc] initWithObject:object];
    [self.mapView addAnnotation:annotation];
}

- (void)configureOverlay {
    //NSLog(@"%@::configureOverlay:",VIEWCONTROLLER_MAP);
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.view addSubview: self.mapView];
    
    // center our map view around this geopoint
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.location.coordinate.latitude,
                                                                                  self.location.coordinate.longitude),
                                                       MKCoordinateSpanMake(0.0025f, 0.0025f));

    // Animate zoom into geopoint center
    [self.mapView setRegion:region animated:NO];
    [self updateLocations];
}

- (void)updateLocations {
    
    //NSLog(@"updateLocations..");
    
    CGFloat miles = self.radius/1000.0f;
    
    for (UIView *mapScrollViewSubView in scrollView.subviews) {
        [mapScrollViewSubView removeFromSuperview];
    }
    
    // Clear the mapItems
    [mapItems removeAllObjects];
    
    PFGeoPoint *nearGeoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                                      longitude:self.location.coordinate.longitude];
    
    PFQuery *queryPlaces = [PFQuery queryWithClassName:kFTPlaceClassKey];
    [queryPlaces whereKey:kFTPlaceLocationKey nearGeoPoint:nearGeoPoint withinMiles:miles]; // In radius
    [queryPlaces whereKey:kFTPlaceVerifiedKey equalTo:[NSNumber numberWithBool:YES]]; // Verified
    [queryPlaces setLimit:QUERY_LIMIT]; // Within limit
    [queryPlaces whereKeyExists:kFTPlaceIconKey]; // Contains an icon
    [queryPlaces whereKeyExists:kFTPlaceLocationKey]; // Contains a geo point
    [queryPlaces findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {            
            if (objects.count > 0) {
                
                for (int i = 0; i < objects.count; i++)
                {
                    PFObject *place = [objects objectAtIndex:i];
                    
                    //NSLog(@"place:%@",place);
                    
                    // Add objects to the mutable array
                    [mapItems addObject:place];
                    
                    CGFloat xOrigin = i * self.view.frame.size.width;
                    CGRect itemFrame = CGRectMake(xOrigin-10, 0, self.view.frame.size.width, SCROLLVIEWITEM_HEIGHT);
                    
                    //FTMapScrollViewItem *mapScrollViewItem = [[FTMapScrollViewItem alloc] initWithFrame:itemFrame AndMapItem:place];
                    FTMapScrollViewItem *mapScrollViewItem = [[FTMapScrollViewItem alloc] initWithFrame:itemFrame place:place];
                    mapScrollViewItem.delegate = self;
                    [scrollView addSubview:mapScrollViewItem];
                    
                    // Set a geo point
                    FTPlaceGeoPointAnnotation *placeGeoPointAnnotation = [[FTPlaceGeoPointAnnotation alloc] initWithPlace:place];
                    [self.mapView addAnnotation:placeGeoPointAnnotation];
                }
                
                [self.mapView addSubview:scrollView];
                [self.mapView bringSubviewToFront:scrollView];
                
                [scrollView setContentSize:CGSizeMake(mapItems.count * self.view.frame.size.width, SCROLLVIEWITEM_HEIGHT)];
            }
        }
    }];
}

- (void)didTapSearchUsers:(PFUser *)aUser {
    //NSLog(@"FTMapViewController::didTapSearchUsers:");
    
    NSString *userType = [aUser objectForKey:kFTUserTypeKey];
    
    if ([userType isEqualToString:kFTUserTypeBusiness]) {
        
        FTPlaceProfileViewController *placeViewController = [[FTPlaceProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [placeViewController setContact:aUser];
        
        [self.navigationController pushViewController:placeViewController animated:YES];
        
    } else {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setMinimumLineSpacing:0];
        [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
        
        FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
        [profileViewController setUser:aUser];
        
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)didTapSearchHashtags:(NSString *)hashtag {
    
    //NSLog(@"FTMapViewController::didTapSearchHashtags:");
    
    FTSearchViewController *searchViewController = [[FTSearchViewController alloc] init];
    [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
    [searchViewController setSearchString:[hashtag lowercaseString]];
    
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)didTapSearch:(NSString *)searchText forUser:(BOOL)isUser {
    
    if (isUser) {
        
        NSString *lowercaseStringWithoutSymbols = [[searchText stringByReplacingOccurrencesOfString:@"@"
                                                                                         withString:EMPTY_STRING] lowercaseString];
        
        FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
        [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
        [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
        [followFriendsViewController querySearchForUser];
        
        [self.navigationController pushViewController:followFriendsViewController animated:YES];
        
    } else {
        
        FTSearchViewController *searchViewController = [[FTSearchViewController alloc] init];
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:[searchText lowercaseString]];
        
        [self.navigationController pushViewController:searchViewController animated:YES];
        
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (aScrollView.contentOffset.x < 0 || aScrollView.contentOffset.x > (aScrollView.contentSize.width - 320))
        [self killScroll];
    
    static NSInteger previousPage = 0;
    
    CGFloat pageWidth = aScrollView.frame.size.width;
    float fractionalPage = aScrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    if (previousPage != page) {
        
        PFObject *mapItem = [mapItems objectAtIndex:page];
        [self setMapCenterWithPoint:[mapItem objectForKey:kFTPlaceLocationKey]];
        
        previousPage = page;
        
        /*
        // Track left and right
        if (previousPage < page) {
            if (mapItem) {
                //NSLog(@"mapItems: %@",mapItems[page]);
                // Using key kFTUserLocationKey, both Post and User classes have a "location" key
                [self setMapCenterWithPoint:[mapItem objectForKey:kFTPlaceLocationKey]];
            }
        } else if (previousPage > page) {
            if (mapItem) {
                //NSLog(@"mapItems: %@",mapItems[page]);
                [self setMapCenterWithPoint:[mapItem objectForKey:kFTPlaceLocationKey]];
            }
        }
        */
    }
}

- (void)killScroll {
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
}

#pragma mark - FT

- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem
              didTapPlace:(PFObject *)place
                  contact:(PFUser *)contact {
    
    //NSLog(@"mapScrollViewItem:didTapPlace:contact:%@",contact);
    
    FTPlaceProfileViewController *placeViewController = [[FTPlaceProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    if (contact) {
        [placeViewController setContact:contact];
    } else {
        [placeViewController setPlace:place];
    }
    [self.navigationController pushViewController:placeViewController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (trimmedComment.length != 0) {
        
    }
    
    [textField setText:EMPTY_STRING];
    return [textField resignFirstResponder];
}

#pragma mark - FTLocationManagerDelegate

- (void)locationManager:(FTLocationManager *)locationManager
  didUpdateUserLocation:(CLLocation *)location
               geoPoint:(PFGeoPoint *)aGeoPoint {
    
    geoPoint = aGeoPoint;
    [self setInitialLocation:location];
    
    // Remove filterButtonsContainer from the superview if applicable
    [errorLocationImage removeFromSuperview];
    
    // refresh the map
    [self.mapView removeFromSuperview];
    [self.view addSubview: self.mapView];
}

- (void)locationManager:(FTLocationManager *)locationManager
       didFailWithError:(NSError *)error {
    
    [self.view addSubview:errorLocationImage];
    
    // Remove map from the superview (mapview) and add them to the view
    [self.mapView removeFromSuperview];
}

#pragma mark - FTBusinessAnnotationViewDelegate

- (void)businessAnnotationView:(FTBusinessAnnotationView *)businessAnnotationView
  didTapBusinessAnnotationView:(id)sender
                    coordinate:(CLLocationCoordinate2D)coordinate {
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.0025f, 0.0025f));
        
        // Animate zoom into geopoint center
        [self.mapView setRegion:region animated:YES];
        
        [UIView animateWithDuration:1 animations:^{
            [scrollView setContentOffset:CGPointMake(businessAnnotationView.position * self.view.frame.size.width,0)];
        }];
    }
}

#pragma mark - FTAmbassadorAnnotationViewDelegate

- (void)ambassadorAnnotationView:(FTAmbassadorAnnotationView *)ambassadorAnnotationView
  didTapAmbassadorAnnotationView:(id)sender {
    //NSLog(@"ambassadorAnnotationView:%d",ambassadorAnnotationView.position);
    [UIView animateWithDuration:1 animations:^{
        [scrollView setContentOffset:CGPointMake(ambassadorAnnotationView.position * self.view.frame.size.width,0)];
    }];
}

@end
