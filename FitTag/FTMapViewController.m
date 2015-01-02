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
#import "FTBusinessGeoPointAnnotation.h"
#import "FTMapScrollView.h"
#import "FTFollowFriendsViewController.h"
#import "FTSearchViewController.h"
#import "FTBusinessProfileViewController.h"
#import "FTNavigationController.h"
#import "FTPostDetailsViewController.h"
#import "FTUserProfileViewController.h"

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
    UIScrollView *scrollView;
    NSMutableArray *mapItems;
    UISearchBar *searchBar;
    UIView *filterButtonsContainer;
    UILabel *fitTagsLabel;
    UILabel *taggersLabel;
    FTSearchQueryType searchQueryType;
    BOOL isUserFilterSelected;
    int position;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) FTSearchViewController *searchViewController;
@property (nonatomic, strong) FTCircleOverlay *targetOverlay;
@property (nonatomic, strong) FTFollowFriendsViewController *followFriendsViewController;
@property (nonatomic, strong) UINavigationController *followFriendsNavController;
@property (nonatomic, strong) FTLocationManager *locationManager;
@property (nonatomic, strong) UIImageView *errorLocationImage;
@property (nonatomic, strong) NSMutableArray *suggestions;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *hashtags;
@property (nonatomic, strong) UITableView *suggestionsTableView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *postButton;
@property (nonatomic, strong) UIImage *searchBarImage;
@end

@implementation FTMapViewController
@synthesize geoPoint;
@synthesize searchViewController;
@synthesize followFriendsViewController;
@synthesize followFriendsNavController;
@synthesize locationManager;
@synthesize errorLocationImage;
@synthesize suggestions;
@synthesize users;
@synthesize hashtags;
@synthesize suggestionsTableView;
@synthesize doneButton;
@synthesize postButton;
@synthesize searchBarImage;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frameRect = self.view.frame;
    
    // init arrays
    mapItems = [[NSMutableArray alloc] init];
    suggestions = [[NSMutableArray alloc] init];
    users = [[NSMutableArray alloc] init];
    hashtags = [[NSMutableArray alloc] init];
    
    [self searchSuggestions];
    
    // init the MKMapView
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.mapView setDelegate:self];
    [self.mapView setShowsBuildings:NO];
    [self.mapView setShowsPointsOfInterest:NO];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setHidden:NO];
    
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
    
    // Searchbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    
    [self.navigationItem setTitleView:searchBar];
    
    // Create searchbar buttons & container
    CGFloat containerY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    filterButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, containerY, frameRect.size.width, 40)];
    [filterButtonsContainer setBackgroundColor:[UIColor whiteColor]];
    [filterButtonsContainer setUserInteractionEnabled:YES];
    [filterButtonsContainer setAlpha:0];
    
    CGFloat suggestionsY = containerY + filterButtonsContainer.frame.size.height;
    
    // config the suggestions tableview
    suggestionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, suggestionsY, frameRect.size.width, 210) style:UITableViewStylePlain];
    [suggestionsTableView setDelegate:self];
    [suggestionsTableView setDataSource:self];
    [suggestionsTableView setAlpha:0];
    
    // config filter
    CGFloat filterButtonWidth = filterButtonsContainer.frame.size.width / 2;
    CGFloat filterButtonHeight = filterButtonsContainer.frame.size.height;
    
    taggersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterButtonWidth, filterButtonHeight)];
    [taggersLabel setText:@"Users"];
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
    [fitTagsLabel setText:@"Hashtags"];
    [fitTagsLabel setFont:BENDERSOLID(16)];
    [fitTagsLabel setBackgroundColor:FT_GRAY];
    [fitTagsLabel setTextColor:FT_RED];
    [fitTagsLabel setTextAlignment:NSTextAlignmentCenter];
    [fitTagsLabel setUserInteractionEnabled:YES];
    
    isUserFilterSelected = YES;

    UITapGestureRecognizer *fittagsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFitTagsLabelAction:)];
    [fittagsTapGesture setNumberOfTapsRequired:1];
    
    [fitTagsLabel addGestureRecognizer:fittagsTapGesture];
    [filterButtonsContainer addSubview:fitTagsLabel];
    
    // config Scrollview
    CGFloat toolbarHeight = (self.navigationController.toolbar.frame.size.height > 0) ? self.navigationController.toolbar.frame.size.height : 44;
    CGFloat scrollViewY = self.mapView.frame.size.height - SCROLLVIEW_HEIGHT - toolbarHeight;
    
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
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButtonAction:)];
    [doneButton setTintColor:[UIColor whiteColor]];
    
    postButton = self.navigationItem.rightBarButtonItem;
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    followFriendsNavController = [[UINavigationController alloc] init];
    [followFriendsNavController setViewControllers:@[ followFriendsViewController ] animated:NO];
    [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Default filter type
    [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [locationManager requestLocationAuthorization];
    
    [searchBar resignFirstResponder];
    [filterButtonsContainer setAlpha:0];
    [suggestionsTableView setAlpha:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FTSuggestionCell *cell = (FTSuggestionCell *)[tableView dequeueReusableCellWithIdentifier:@"DataCell"];
    if (cell == nil) {
        cell = [[FTSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DataCell"];
        [cell setDelegate:self];
    }
    
    if (suggestions && suggestions.count) {
        //NSLog(@"%@",[suggestions objectAtIndex:indexPath.row]);
        if (isUserFilterSelected) {
            PFUser *user = (PFUser *)[suggestions objectAtIndex:indexPath.row];
            [cell setUser:user];
        } else {
            [cell setHashtag:[suggestions objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

#pragma mark - FTSuggestionTableViewCellDelegate

- (void)suggestionView:(FTSuggestionCell *)suggestionView didSelectHashtag:(NSString *)hashtag {
    [searchBar resignFirstResponder];
    [filterButtonsContainer setAlpha:0];
    [suggestionsTableView setAlpha:0];
    
    [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
    [searchViewController setSearchString:[hashtag lowercaseString]];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)suggestionView:(FTSuggestionCell *)suggestionView didSelectUser:(PFUser *)aUser {
    [searchBar resignFirstResponder];
    [filterButtonsContainer setAlpha:0];
    [suggestionsTableView setAlpha:0];
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapPopSearchButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.mapView.frame.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    
    NSString *userType = [aUser objectForKey:kFTUserTypeKey];
    
    if ([userType isEqualToString:kFTUserTypeBusiness]) {
        
        [flowLayout setHeaderReferenceSize:CGSizeMake(self.mapView.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
        
        FTBusinessProfileViewController *profileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
        [profileViewController setBusiness:aUser];
        [profileViewController.navigationItem setLeftBarButtonItem:backIndicator];
        [self.navigationController pushViewController:profileViewController animated:YES];
    } else {
        
        [flowLayout setHeaderReferenceSize:CGSizeMake(self.mapView.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
        
        FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
        [profileViewController setUser:aUser];
        [profileViewController.navigationItem setLeftBarButtonItem:backIndicator];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar {
    
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    NSLog(@"started editing..");
    
    [self.suggestions removeAllObjects];
    
    if (isUserFilterSelected) {
        [self.suggestions addObjectsFromArray:users];
    } else {
        [self.suggestions addObjectsFromArray:hashtags];
    }
    [suggestionsTableView reloadData];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [filterButtonsContainer setAlpha:1];
        [suggestionsTableView setAlpha:1];
    }];
    
    if (aSearchBar.text.length > 0) {
        [self updateSuggestions:aSearchBar.text];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    //NSLog(@"searchText:%@",searchBar.text);
    
    [self.navigationItem setRightBarButtonItem:postButton];
    
    [searchBar resignFirstResponder];
    [filterButtonsContainer setAlpha:0];
    [suggestionsTableView setAlpha:0];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSuggestions:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar {
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [filterButtonsContainer setAlpha:0];
        [suggestionsTableView setAlpha:0];
    }];
    
    if (isUserFilterSelected) {
        NSString *lowercaseStringWithoutSymbols = [[searchBar.text stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING] lowercaseString];
        [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
        [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
        [followFriendsViewController querySearchForUser];
        [self presentViewController:followFriendsNavController animated:YES completion:nil];
    } else {
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:[searchBar.text lowercaseString]];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [filterButtonsContainer setAlpha:0];
        [suggestionsTableView setAlpha:0];
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
            annotationView.position = position;
            annotationView.delegate = self;
            position++;
        }
        return annotationView;
        
    } else if ([annotation isKindOfClass:[FTBusinessGeoPointAnnotation class]]) {
    
        FTBusinessAnnotationView *annotationView = (FTBusinessAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointBusinessAnnotationIdentifier];
        if (!annotationView) {            
            annotationView = [[FTBusinessAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GeoPointBusinessAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = NO;
            annotationView.draggable = NO;
            annotationView.position = position;
            annotationView.delegate = self;
            FTBusinessGeoPointAnnotation *businessGeoPointAnnotation = annotation;
            annotationView.file = [businessGeoPointAnnotation file];
            position++;
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
    if ([object objectForKey:kFTPostLocationKey]) {
        geoPoint = [object objectForKey:kFTPostLocationKey];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        if (location) {
            self.location = location;
            [self configurePostOverlay:object];
        }
    }
}

- (void)setInitialLocation:(CLLocation *)aLocation {
    //NSLog(@"%@::setInitialLocation: %@",VIEWCONTROLLER_MAP,aLocation);
    if (!self.location) {
        self.location = aLocation;
        [self configureOverlay];
    }
}

#pragma mark - ()

- (void)updateSuggestions:(NSString *)searchText {
    [suggestions removeAllObjects];
    
    if (isUserFilterSelected) {
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:users];
            [suggestionsTableView reloadData];
            return;
        }
        
        for (PFUser *user in users) {
            NSString *displayName = [user objectForKey:kFTUserDisplayNameKey];
            NSRange substringRange = [[displayName lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:user];
            }
        }
        
    } else {
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:hashtags];
            [suggestionsTableView reloadData];
            return;
        }
        
        for (NSString *hashtag in hashtags) {
            NSRange substringRange = [[hashtag lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:hashtag];
            }
        }
    }
    
    [suggestionsTableView reloadData];
}

- (void)didTapDoneButtonAction:(id)sender {
    
    [searchBar resignFirstResponder];
    [filterButtonsContainer setAlpha:0];
    [suggestionsTableView setAlpha:0];
}

- (void)searchSuggestions {
    
    PFQuery *usersQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [usersQuery  whereKeyExists:kFTUserDisplayNameKey];
    [usersQuery  whereKeyExists:kFTUserProfilePicSmallKey];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *userObjects, NSError *error) {
        if (!error) {
            
            NSMutableArray *userSuggestions = [[NSMutableArray alloc] initWithArray:userObjects];
            NSMutableArray *displayNames = [[NSMutableArray alloc] init];
            
            // Get array of names
            for (PFUser *user in users) {
                [displayNames addObject:[user objectForKey:kFTUserDisplayNameKey]];
            }
            
            for (PFUser *userSuggestion in userSuggestions) {
                
                NSString *displayName = [userSuggestion objectForKey:kFTUserDisplayNameKey];
                
                if (![displayNames containsObject:displayName]) {
                    NSLog(@"displayName:%@",displayName);
                    [users addObject:userSuggestion];
                }
            }
            //NSLog(@"users:%@",users);
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
    
    PFQuery *hashtagQuery = [PFQuery queryWithClassName:kFTPostClassKey];
    [hashtagQuery whereKeyExists:kFTPostHashTagKey];
    [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //[self.suggestions removeAllObjects];
            
            NSMutableArray *hashtagSuggestions = [[NSMutableArray alloc] initWithArray:objects]; // array of PFObjects
            
            for (PFObject *object in hashtagSuggestions) { // loop throught PFObjects
                NSMutableArray *postHashtags = [object objectForKey:kFTPostHashTagKey]; // array of hashtags
                for (NSString *postHashtag in postHashtags) { // loop through array of hashtags
                    if (![hashtags containsObject:postHashtag]) { // if unique insert into our array else skip
                        NSLog(@"postHashtag:%@",postHashtag);
                        [hashtags addObject:postHashtag];
                    }
                }
            }
            //NSLog(@"hashtagObjects:%@",hashtags);
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
}

- (void)didTapPopSearchButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shouldDismissViewGesture:(id)sender {
    [searchBar resignFirstResponder];
}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapTaggersLabelAction:(id)sender {
    NSLog(@"%@::didTapTaggersLabelAction:",VIEWCONTROLLER_MAP);
    isUserFilterSelected = YES;
    [fitTagsLabel setBackgroundColor:FT_GRAY];
    [fitTagsLabel setTextColor:FT_RED];
    
    [taggersLabel setBackgroundColor:[UIColor whiteColor]];
    [taggersLabel setTextColor:[UIColor blackColor]];
    
    /*
    [searchBar setImage:[self imageFromText:@"@"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
    */
    
    [self.suggestions removeAllObjects];
    [self.suggestions addObjectsFromArray:users];
    [suggestionsTableView reloadData];
}

- (void)didTapFitTagsLabelAction:(id)sender {
    NSLog(@"%@::didTapFitTagsLabelAction:",VIEWCONTROLLER_MAP);
    isUserFilterSelected = NO;
    [taggersLabel setBackgroundColor:FT_GRAY];
    [taggersLabel setTextColor:FT_RED];
    
    [fitTagsLabel setBackgroundColor:[UIColor whiteColor]];
    [fitTagsLabel setTextColor:[UIColor blackColor]];
    
    /*
    [searchBar setImage:[self imageFromText:@"#"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
    */
    
    [self.suggestions removeAllObjects];
    [self.suggestions addObjectsFromArray:hashtags];
    [suggestionsTableView reloadData];
}

- (UIImage *)imageFromText:(NSString *)text {
    
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:12.0f]}];
    
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        UIGraphicsBeginImageContext(size);
    
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:@{NSFontAttributeName:
                                                                 [UIFont systemFontOfSize:12.0f]}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setMapCenterWithPoint:(PFGeoPoint *)centerPoint {
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerPoint.latitude, centerPoint.longitude), MKCoordinateSpanMake(0.0225f, 0.0225f));
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
                                                       MKCoordinateSpanMake(0.0225f, 0.0225f));
    
    // Animate zoom into geopoint center
    [self.mapView setRegion:region animated:NO];
    
    FTAmbassadorGeoPointAnnotation *annotation = [[FTAmbassadorGeoPointAnnotation alloc] initWithObject:object];
    [self.mapView addAnnotation:annotation];
}

- (void)configureOverlay {
    NSLog(@"%@::configureOverlay:",VIEWCONTROLLER_MAP);
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.view addSubview: self.mapView];
    
    // center our map view around this geopoint
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.location.coordinate.latitude,
                                                                                  self.location.coordinate.longitude),
                                                       MKCoordinateSpanMake(0.0225f, 0.0225f));

    // Animate zoom into geopoint center
    [self.mapView setRegion:region animated:NO];
    [self updateLocations];
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
                    
                    if (mapItems.count > 0) {
                        [self.mapView addSubview:scrollView];
                        [self.mapView bringSubviewToFront:scrollView];
                        
                        [scrollView setContentSize:CGSizeMake(mapItems.count * self.view.frame.size.width, SCROLLVIEWITEM_HEIGHT)];                        
                    }
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
    [flowLayout setItemSize:CGSizeMake(self.mapView.frame.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.mapView.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
        
    FTBusinessProfileViewController *profileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setBusiness:aUser];
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

#pragma mark - FTLocationManagerDelegate

- (void)locationManager:(FTLocationManager *)locationManager didUpdateUserLocation:(CLLocation *)location geoPoint:(PFGeoPoint *)aGeoPoint {
    geoPoint = aGeoPoint;
    [self setInitialLocation:location];
    
    // Remove filterButtonsContainer from the superview if applicable
    [errorLocationImage removeFromSuperview];
    
    // refresh the map
    [self.mapView removeFromSuperview];
    [self.view addSubview: self.mapView];
    
    // refresh the filter buttons
    [filterButtonsContainer removeFromSuperview];
    [self.mapView addSubview:filterButtonsContainer];
    [self.mapView bringSubviewToFront:filterButtonsContainer];
    
    // refresh the suggestions table
    [suggestionsTableView removeFromSuperview];
    [self.mapView addSubview:suggestionsTableView];
    [self.mapView bringSubviewToFront:suggestionsTableView];
}

- (void)locationManager:(FTLocationManager *)locationManager didFailWithError:(NSError *)error {
    [self.view addSubview:errorLocationImage];
    
    // Remove filterButtonsContainer & map from the superview (mapview) and add them to the view
    [filterButtonsContainer removeFromSuperview];
    [suggestionsTableView removeFromSuperview];
    [self.mapView removeFromSuperview];
    
    [self.view addSubview:filterButtonsContainer];
    [self.view bringSubviewToFront:filterButtonsContainer];
    
    [self.mapView addSubview:suggestionsTableView];
    [self.mapView bringSubviewToFront:suggestionsTableView];
}

#pragma mark - FTBusinessAnnotationViewDelegate

- (void)businessAnnotationView:(FTBusinessAnnotationView *)businessAnnotationView didTapBusinessAnnotationView:(id)sender {
    NSLog(@"businessAnnotationView:%d",businessAnnotationView.position);
    [UIView animateWithDuration:1 animations:^{
        [scrollView setContentOffset:CGPointMake(businessAnnotationView.position * self.view.frame.size.width,0)];
    }];
}

#pragma mark - FTAmbassadorAnnotationViewDelegate

- (void)ambassadorAnnotationView:(FTAmbassadorAnnotationView *)ambassadorAnnotationView didTapAmbassadorAnnotationView:(id)sender {
    NSLog(@"ambassadorAnnotationView:%d",ambassadorAnnotationView.position);
    [UIView animateWithDuration:1 animations:^{
        [scrollView setContentOffset:CGPointMake(ambassadorAnnotationView.position * self.view.frame.size.width,0)];
    }];
}

@end
