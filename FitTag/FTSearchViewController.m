//
//  FTSearchResultsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchViewController.h"
#import "FTPhotoDetailsViewController.h"
#import "FTAccountViewController.h"
#import "FTUtility.h"
#import "FTLoadMoreCell.h"
#import "FTMapViewController.h"

static NSString *const NothingFoundCellIdentifier = @"NothingFoundCell";

@interface FTSearchViewController (){
    CLLocationManager *locationManager;
}
@end

@interface FTSearchViewController()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) PFGeoPoint *geoPoint;

// Searchbar
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) FTSearchHeaderView *searchHeaderView;
@end

@implementation FTSearchViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize searchResults;
@synthesize searchHeaderView;
@synthesize geoPoint;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // I created a dummy class to avoid it automatically download data
        self.parseClassName = @"Dummy";
        
        //self.textKey = @"restaurantName";
        
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = NO;
        
        self.objectsPerPage = 10;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    // Update the users location
    [[self locationManager] startUpdatingLocation];
    
    // Set title
    [self.navigationItem setTitle: @"SEARCH"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set back indicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Set map indicator
    UIBarButtonItem *mapIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_button"] style:UIBarButtonItemStylePlain target:self action:@selector(loadNearbyMap:)];
    [mapIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:mapIndicator];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    searchHeaderView = [[FTSearchHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    searchHeaderView.delegate = self;
    searchHeaderView.searchbar.delegate = self;
    
    // Dismiss keyboard gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard:(id)sender {
    if (searchHeaderView.searchbar != nil)
        [searchHeaderView.searchbar resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self clearSelectedFilters];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (searchResults == nil) {
        return 0;
    } else if ([searchResults count] == 0) {
        return 1;
    } else {
        return [searchResults count];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath %ld",(long)indexPath.row);
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
    
    NSLog(@"tableView:didSelectRowAtIndexPath:");
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"willSelectRowAtIndexPath %ld",(long)indexPath.row);

    if ([searchResults count] == 0) {
        return nil;
    } else {
        return indexPath;
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = searchHeaderView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"FTSearchResultsViewController::tableView:(UITableView *) %@ cellForRowAtIndexPath:(NSIndexPath *) %@ object:(PFObject *) %@",tableView,indexPath,object);

    static NSString *identifier = @"SearchCell";
        
    //Custom Cell
    FTSearchCell *searchCell = (FTSearchCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (searchCell == nil) {
        searchCell = [[FTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [searchCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [searchCell setDelegate:self];
    }
    
    if ([searchResults count] == 0) {
        static NSString *emptyIdentifier = @"EmptyCell";
        FTSearchCell *emptyCell = (FTSearchCell *)[tableView dequeueReusableCellWithIdentifier:emptyIdentifier];
        if (emptyCell == nil) {
            emptyCell = [[FTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyIdentifier];
        }
        [emptyCell setName:@"No results found..."];
        return emptyCell;
        
    } else {
        @synchronized(self) {
            
            PFObject *object = [PFObject objectWithClassName:kFTActivityClassKey];
            object = [searchResults objectAtIndex:indexPath.row];
            
            //NSLog(@"object: %@",object);
            
            if ([[object parseClassName] isEqual: @"_User"]) {
                NSString *displayName = [object objectForKey:kFTUserFirstnameKey];
                displayName = [displayName stringByAppendingString:@" "];
                displayName = [displayName stringByAppendingString:[object objectForKey:kFTUserlastnameKey]];
                displayName = [displayName stringByAppendingString:@" "];
                displayName = [displayName stringByAppendingString:[object objectForKey:kFTUserDisplayNameKey]];
                [searchCell setName:displayName];
                [searchCell setIcon:[self getIconTypeInteger:[object objectForKey:kFTUserTypeKey]]];
                [searchCell setUser:(PFUser *)object];
            }
            
            /*
            if ([[object parseClassName]  isEqual: @"Activity"]) {
                PFObject *toUser = [PFObject objectWithClassName:kFTUserClassKey];
                toUser = [object objectForKey:kFTActivityToUserKey];

                NSLog(@"type ---------- %@",[object objectForKey:kFTActivityTypeKey]);
                NSString *displayName = [[object objectForKey:kFTActivityHashtagKey] componentsJoinedByString:@", "];
                
                if (displayName == nil) {
                    displayName = [[object objectForKey:kFTActivityMentionKey] componentsJoinedByString:@", "];
                }
                
                if (displayName == nil) {
                    displayName = [object objectForKey:kFTActivityContentKey];
                }
                
                [searchCell setName:displayName];
                [searchCell setIcon:[self getIconTypeInteger:@"hashtag"]];
                [searchCell setUser:(PFUser *)toUser];
            }
            */
            
            if ([[object parseClassName]  isEqual: @"Post"]) {
                PFObject *user = [PFObject objectWithClassName:kFTUserClassKey];
                user = [object objectForKey:kFTPostUserKey];
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSString *displayName = [user objectForKey:kFTUserFirstnameKey];
                    displayName = [displayName stringByAppendingString:@" "];
                    displayName = [displayName stringByAppendingString:[user objectForKey:kFTUserlastnameKey]];
                    displayName = [displayName stringByAppendingString:@" "];
                    displayName = [displayName stringByAppendingString:[user objectForKey:kFTUserDisplayNameKey]];
                    [searchCell setName:displayName];
                }];
                [searchCell setIcon:[self getIconTypeInteger:@"trending"]];
                [searchCell setPost:object];
            }
        }
    }
    return searchCell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark - ()

- (NSInteger)getIconTypeInteger:(NSString *)type{
    
    if([type isEqualToString:@"popular"]){
        return 1;
    } else if([type isEqualToString:@"trending"]){
        return 2;
    } else if([type isEqualToString:@"user"]){
        return 3;
    } else if([type isEqualToString:@"business"]){
        return 4;
    } else if([type isEqualToString:@"ambassador"]){
        return 5;
    } else if([type isEqualToString:@"nearby"]){
        return 6;
    } else if([type isEqualToString:@"hashtag"]){
        return 7;
    } else {
        return 0;
    }
}

- (void)returnHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadNearbyMap:(id)sender{
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    [mapViewController setInitialLocation:locationManager.location];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (NSMutableArray *) checkForWords:(UITextField *)textField {
    NSMutableArray *words = [[NSMutableArray alloc] initWithArray:[[textField.text componentsSeparatedByString:@" "] mutableCopy]];
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    for (NSString *word in words) {
        NSString *firstCharacter = [word substringToIndex:1];
        if (![firstCharacter isEqual:@"#"] && ![firstCharacter isEqual:@"@"]) {
            if ([word length] > 3)
                [matches addObject:word];
        }
    }
    return matches;
}

- (NSMutableArray *) checkForHashtag:(UITextField *)textField {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textField.text options:0 range:NSMakeRange(0,textField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [textField.text substringWithRange:wordRange];
        //NSLog(@"Found tag %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (NSMutableArray *) checkForMention:(UITextField *)textField {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textField.text options:0 range:NSMakeRange(0,textField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [textField.text substringWithRange:wordRange];
        //NSLog(@"Found mention %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (trimmedComment.length != 0) {
        
        [searchResults removeAllObjects];
        searchResults = [NSMutableArray arrayWithCapacity:50];
        
        PFQuery *activityQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
        [activityQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
        [activityQuery includeKey:kFTActivityPostKey];
        [activityQuery includeKey:kFTActivityToUserKey];
        [activityQuery setLimit:1000];
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[self checkForHashtag:textField]];
        //NSLog(@"hashtags: %@",hashtags);
        
        // Hashtags detected
        if (hashtags.count > 0) {
            [activityQuery whereKey:kFTActivityHashtagKey containedIn:hashtags];
        }
        
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[self checkForMention:textField]];
        //NSLog(@"mentions: %@",mentions);
        
        // Mentions detected
        if (mentions.count > 0) {
            [activityQuery whereKey:kFTActivityHashtagKey containedIn:mentions];
        }
        
        NSMutableArray *words = [[NSMutableArray alloc] initWithArray:[self checkForWords:textField]];
        //NSLog(@"words: %@",words);
        
        // Mentions detected
        if (words.count > 0) {
            [activityQuery whereKey:kFTActivityWordKey containedIn:words];
        }
        
        // Nearby button is selected
        PFQuery *userQuery = nil;
        PFQuery *postQuery = nil;
        if ([searchHeaderView isNearbyButtonSelected]) {
            CGFloat miles = 50.0f;
            
            if (geoPoint != nil) {
                userQuery = [PFQuery queryWithClassName:kFTUserClassKey];
                [userQuery whereKey:kFTUserLocationKey nearGeoPoint:geoPoint withinMiles:miles];
                [activityQuery whereKey:kFTActivityFromUserKey matchesQuery:userQuery];
                
                // Nearby button in combination with trending OR popular
                if ([searchHeaderView isPopularButtonSelected] || [searchHeaderView isTrendingButtonSelected]) {
                    postQuery = [PFQuery queryWithClassName:kFTPostClassKey];
                    [postQuery whereKey:kFTPostLocationKey nearGeoPoint:geoPoint withinMiles:miles];
                    [activityQuery whereKey:kFTActivityPostKey matchesQuery:postQuery];
                }
            }
        }
        
        [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                NSMutableArray *userType = [[NSMutableArray alloc] init];
                NSDate *today = [NSDate date];
                NSDate *trendRange = nil;
                
                // Treding button is selected
                if ([searchHeaderView isTrendingButtonSelected]) {
                    trendRange = [today dateByAddingTimeInterval: -259200.0];
                }
                
                // If an user type is selected add it to our array and use it as a constraint
                if ([searchHeaderView isUserButtonSelected])
                    [userType addObject:kFTUserTypeUser];
                if ([searchHeaderView isBusinessButtonSelected])
                    [userType addObject:kFTUserTypeBusiness];
                if ([searchHeaderView isAmbassadorButtonSelected])
                    [userType addObject:kFTUserTypeAmbassador];

                for (PFObject *object in objects) {
                    PFUser *user = [object objectForKey:kFTActivityToUserKey];
                    PFObject *post = [object objectForKey:kFTActivityPostKey];
                    //PFObject *activity = object;
                    
                    if (user != nil && ![self array:searchResults containsPFObjectById:user] && [userType containsObject:[user objectForKey:kFTUserTypeKey]])
                        [searchResults addObject:user];
                    //if (activity != nil && ![self array:searchResults containsPFObjectById:activity])
                        //[searchResults addObject:activity];
                    
                    // If trending button is selected
                    if (post != nil) {
                        if (trendRange != nil) {
                            if (![self array:searchResults containsPFObjectById:post])
                                if ([post createdAt] > trendRange)
                                    [searchResults addObject:post];
                        } else {
                            if (![self array:searchResults containsPFObjectById:post])
                                [searchResults addObject:post];
                        }
                    }
                }
                
                if (searchResults != nil) {
                    [self loadObjects];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Empty search" message:@"no results found" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil] show];
                }
            }
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

- (BOOL) array:(NSArray *)array containsPFObjectById:(PFObject *)object {
    //Check if the object's objectId matches the objectId of any member of the array.
    for (PFObject *arrayObject in array) {
        if ([[arrayObject objectId] isEqual:[object objectId]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
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
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        CLLocation *location = [locations lastObject];
        //NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
        
        geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                          longitude:location.coordinate.longitude];
        
        user[@"location"] = geoPoint;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"FTSearchViewController::locationManager:didUpdateLocations: //User location updated successfully.");
            }
        }];
    }
}

#pragma mark - FTSearchCellDelegate

-(void)cellView:(PFTableViewCell *)cellView didTapCellLabelButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapCellLabelButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapAmbassadorCellIconButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapAmbassadorCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
}

-(void)cellView:(PFTableViewCell *)cellView didTapHashtagCellIconButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapHashtagCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapNearbyCellIconButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapNearbyCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
}

-(void)cellView:(PFTableViewCell *)cellView didTapPopularCellIconButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapPopularCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapTrendingCellIconButton:(UIButton *)button post:(PFObject *)post{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapTrendingCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,post);
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapUserCellIconButton:(UIButton *)button user:(PFUser *)user{
    NSLog(@"cellView:(PFTableViewCell *) %@ didTapUserCellIconButton:(UIButton *) %@ post:(PFObject *) %@",cellView,button,user);
    if (user != nil) {
        FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        [accountViewController setUser:user];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}

#pragma mark - FT

-(void)searchHeaderView:(FTSearchHeaderView *)searchHeaderView didChangeFrameSize:(CGRect)rect{
    [self.searchHeaderView setFrame:rect];
    self.tableView.tableHeaderView = self.searchHeaderView;
}

@end
