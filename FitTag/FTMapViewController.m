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
#import "FTFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "FTSearchViewController.h"
#import "FTBusinessProfileViewController.h"
#import "FTNavigationController.h"
#import "FTPostDetailsViewController.h"

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
    CLLocationManager *locationManager;
    UIScrollView *scrollView;
    NSMutableArray *mapItems;
    UISearchBar *searchBar;
    UIView *filterButtonsContainer;
    UILabel *fitTagsLabel;
    UILabel *taggersLabel;
    FTSearchQueryType searchQueryType;
    BOOL isTaggersSelected;
    UIColor *redColor;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) FTSearchViewController *searchViewController;
@property (nonatomic, strong) FTSearchHeaderView *searchHeaderView;
@property (nonatomic, strong) FTCircleOverlay *targetOverlay;
@property (nonatomic, strong) FTInviteFriendsViewController *inviteFriendsViewController;
@property (nonatomic, strong) UINavigationController *inviteFriendsNavController;
@end

@implementation FTMapViewController
@synthesize searchHeaderView;
@synthesize geoPoint;
@synthesize searchViewController;
@synthesize inviteFriendsViewController;
@synthesize inviteFriendsNavController;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    redColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                               green:FT_RED_COLOR_GREEN
                                blue:FT_RED_COLOR_BLUE
                               alpha:1.0f];
    
    mapItems = [[NSMutableArray alloc] init];
    
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
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Set radius
    self.radius = KILOMETER_FIVE;
    
    // Searchbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    
    [self.navigationItem setTitleView:searchBar];
    
    // Create searchbar buttons & container
    CGFloat containerY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    filterButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, containerY, self.view.frame.size.width, 40)];
    [filterButtonsContainer setBackgroundColor:[UIColor whiteColor]];
    [filterButtonsContainer setUserInteractionEnabled:YES];
    [filterButtonsContainer setAlpha:0];
    
    CGFloat filterButtonWidth = filterButtonsContainer.frame.size.width / 2;
    CGFloat filterButtonHeight = filterButtonsContainer.frame.size.height;
    
    taggersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterButtonWidth, filterButtonHeight)];
    [taggersLabel setText:@"Taggers"];
    [taggersLabel setFont:BENDERSOLID(16)];
    [taggersLabel setBackgroundColor:[UIColor whiteColor]];
    [taggersLabel setTextColor:[UIColor blackColor]];
    [taggersLabel setTextAlignment:NSTextAlignmentCenter];
    [taggersLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *taggersTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTaggersLabelAction:)];
    [taggersTapGesture setNumberOfTapsRequired:1];
    [taggersLabel addGestureRecognizer:taggersTapGesture];
    [filterButtonsContainer addSubview:taggersLabel];
    
    fitTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(filterButtonWidth, 0, filterButtonWidth, filterButtonHeight)];
    [fitTagsLabel setText:@"FitTags"];
    [fitTagsLabel setFont:BENDERSOLID(16)];
    [fitTagsLabel setBackgroundColor:[UIColor whiteColor]];
    [fitTagsLabel setTextColor:[UIColor blackColor]];
    [fitTagsLabel setTextAlignment:NSTextAlignmentCenter];
    [fitTagsLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *fittagsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFitTagsLabelAction:)];
    [fittagsTapGesture setNumberOfTapsRequired:1];
    [fitTagsLabel addGestureRecognizer:fittagsTapGesture];
    [filterButtonsContainer addSubview:fitTagsLabel];
    
    [self.mapView addSubview:filterButtonsContainer];
    [self.mapView bringSubviewToFront:filterButtonsContainer];
    
    
    // Scrollview
    CGFloat scrollViewY = self.mapView.frame.size.height - SCROLLVIEW_HEIGHT - self.navigationController.toolbar.frame.size.height;
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
    
    // Init search view controller
    UIBarButtonItem *dismissSearchButton = [[UIBarButtonItem alloc] init];
    [dismissSearchButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissSearchButton setStyle:UIBarButtonItemStylePlain];
    [dismissSearchButton setTarget:self];
    [dismissSearchButton setAction:@selector(didTapPopSearchButtonAction:)];
    [dismissSearchButton setTintColor:[UIColor whiteColor]];
    
    searchViewController = [[FTSearchViewController alloc] init];
    [searchViewController.navigationItem setLeftBarButtonItem:dismissSearchButton];
    
    // Init search user controller
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    inviteFriendsViewController = [[FTInviteFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    inviteFriendsNavController = [[UINavigationController alloc] init];
    [inviteFriendsNavController setViewControllers:@[ inviteFriendsViewController ] animated:NO];
    [inviteFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Default filter type
    [fitTagsLabel setBackgroundColor:redColor];
    [fitTagsLabel setTextColor:[UIColor whiteColor]];
    [taggersLabel setBackgroundColor:[UIColor whiteColor]];
    [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
    isTaggersSelected = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Navigation Bar

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

#pragma mark - SearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
       [filterButtonsContainer setAlpha:1];
    }];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar {
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [filterButtonsContainer setAlpha:0];
    }];
    
    if (isTaggersSelected) {
        [inviteFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
        [inviteFriendsViewController setSearchString:searchBar.text];
        [inviteFriendsViewController querySearchForUser];
        [self presentViewController:inviteFriendsNavController animated:YES completion:nil];
    } else {
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:searchBar.text];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (void)didTapPopSearchButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [filterButtonsContainer setAlpha:0];
    }];
}

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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
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

#pragma mark - SearchViewController

- (void)setInitialLocation:(CLLocation *)aLocation {
    NSLog(@"%@::setInitialLocation: %@",VIEWCONTROLLER_MAP,aLocation);
    self.location = aLocation;
    [self configureOverlay];
}

#pragma mark - ()

- (void)didTapBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapTaggersLabelAction:(id)sender {
    NSLog(@"%@::didTapTaggersLabelAction:",VIEWCONTROLLER_MAP);
    isTaggersSelected = YES;
    [taggersLabel setBackgroundColor:redColor];
    [taggersLabel setTextColor:[UIColor whiteColor]];
    
    [fitTagsLabel setBackgroundColor:[UIColor whiteColor]];
    [fitTagsLabel setTextColor:[UIColor blackColor]];
}

- (void)didTapFitTagsLabelAction:(id)sender {
    NSLog(@"%@::didTapFitTagsLabelAction:",VIEWCONTROLLER_MAP);
    isTaggersSelected = NO;
    [fitTagsLabel setBackgroundColor:redColor];
    [fitTagsLabel setTextColor:[UIColor whiteColor]];
    
    [taggersLabel setBackgroundColor:[UIColor whiteColor]];
    [taggersLabel setTextColor:[UIColor blackColor]];
}

- (void)setMapCenterWithPoint:(PFGeoPoint *)centerPoint {
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerPoint.latitude, centerPoint.longitude), MKCoordinateSpanMake(0.0225f, 0.0225f));
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    CGFloat miles = self.radius/1000.0f;
    
    for (UIView *mapScrollViewSubView in scrollView.subviews) {
        [mapScrollViewSubView removeFromSuperview];
    }
    
    // Clear the mapItems
    [mapItems removeAllObjects];
    
    PFGeoPoint *nearGeoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                                      longitude:self.location.coordinate.longitude];
    
    PFQuery *queryBusinessUsers = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryBusinessUsers whereKey:kFTUserTypeKey equalTo:kFTUserTypeBusiness];
    [queryBusinessUsers whereKey:kFTUserLocationKey nearGeoPoint:nearGeoPoint withinMiles:miles];
    [queryBusinessUsers setLimit:QUERY_LIMIT];
    [queryBusinessUsers orderByAscending:kFTUserLocationKey];
    [queryBusinessUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //NSLog(@"Business Locations: %@", objects);
            for (PFObject *object in objects) {
                
                // Add objects to the mutable array
                [mapItems addObject:object];
                
                // Set a geo point
                FTBusinessGeoPointAnnotation *businessGeoPointAnnotation = [[FTBusinessGeoPointAnnotation alloc] initWithObject:object];
                [self.mapView addAnnotation:businessGeoPointAnnotation];
            }
            
            PFQuery *innerQuery = [PFQuery queryWithClassName:kFTUserClassKey];
            [innerQuery whereKey:kFTUserTypeKey equalTo:kFTUserTypeAmbassador];
            
            PFQuery *query = [PFQuery queryWithClassName:kFTPostClassKey];
            [query whereKeyExists:kFTPostLocationKey];
            [query whereKey:kFTPostUserKey matchesQuery:innerQuery];
            [query includeKey:kFTPostUserKey];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *object in objects) {
                        [mapItems addObject:object];
                        
                        FTAmbassadorGeoPointAnnotation *ambassadorGeoPointAnnotation = [[FTAmbassadorGeoPointAnnotation alloc] initWithObject:object];
                        [self.mapView addAnnotation:ambassadorGeoPointAnnotation];
                    }
                    
                    int i = 0;
                    for (PFObject *mapItem in mapItems) {
                        
                        CGFloat xOrigin = i * self.view.frame.size.width;
                        CGRect itemFrame = CGRectMake(xOrigin-10, 0, self.view.frame.size.width, SCROLLVIEWITEM_HEIGHT);
                        FTMapScrollViewItem *mapScrollViewItem = [[FTMapScrollViewItem alloc] initWithFrame:itemFrame AndMapItem:mapItem];
                        mapScrollViewItem.delegate = self;
                        [scrollView addSubview:mapScrollViewItem];
                        
                        i++;
                    }
                    
                    [self.mapView addSubview:scrollView];
                    [self.mapView bringSubviewToFront:scrollView];
                    
                    [scrollView setContentSize: CGSizeMake(mapItems.count * self.view.frame.size.width, SCROLLVIEWITEM_HEIGHT)];
                }
            }];
        }
    }];
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
        if (previousPage < page) {
            if (mapItems[page]) {
                //NSLog(@"mapItems: %@",mapItems[page]);
                // Using key kFTUserLocationKey, both Post and User classes have a "location" key
                [self setMapCenterWithPoint:[mapItems[page] objectForKey:kFTUserLocationKey]];
            }
        } else if (previousPage > page) {
            if (mapItems[page]) {
                //NSLog(@"mapItems: %@",mapItems[page]);
                [self setMapCenterWithPoint:[mapItems[page] objectForKey:kFTUserLocationKey]];
            }
        }
        previousPage = page;
    }
}

- (void)killScroll {
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
}

#pragma mark - FT

- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem didTapPostItem:(UIButton *)button post:(PFObject *)aPost {
    FTPostDetailsViewController *postDetailView = [[FTPostDetailsViewController alloc] initWithPost:aPost AndType:nil];
    [self.navigationController pushViewController:postDetailView animated:YES];
}

- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem didTapUserItem:(UIButton *)button user:(PFUser *)aUser {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.mapView.frame.size.width,335)];
    
    // Override the back idnicator
    UIBarButtonItem *dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
    [dismissProfileButton setTintColor:[UIColor whiteColor]];
    
    FTBusinessProfileViewController *profileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setBusiness:aUser];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
    //NSLog(@"%@::didFailWithError: %@", VIEWCONTROLLER_MAP, error);
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
