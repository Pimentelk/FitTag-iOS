//
//  FitTagLoginViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTConfigViewController.h"
#import "FTLoginViewController.h"
#import "FTSignupViewController.h"
#import "FTInterestsViewController.h"
#import "InterestCollectionViewFlowLayout.h"
#import "FeedCollectionViewFlowLayout.h"
#import "FTToolBar.h"
#import "FTFeedViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "FTMapViewController.h"
#import "AppDelegate.h"

@interface FTConfigViewController () {
    FTLoginViewController *logInViewController;
    FTSignupViewController *signUpViewController;
    CLLocationManager *locationManager;
}
@end

@implementation FTConfigViewController
@synthesize firstLaunch;

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSLog(@"%@::viewWillAppear:",VIEWCONTROLLER_CONFIG);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@::viewDidAppear:",VIEWCONTROLLER_CONFIG);
    
    // If not logged in, present login view controller
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
    
    if (![PFUser currentUser]) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    
    // Present FitTag UI
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    //[[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[PFUser logOut]; // For testing log out user.
    PFUser *user = [PFUser currentUser];
    BOOL isFirstUserLogin = YES;
    
    if ([user objectForKey:@"lastLogin"]) {
        isFirstUserLogin = NO;
    }
    
    // Check if user object is set
    if (user) {
     
        // Start Updating Location
        [[self locationManager] startUpdatingLocation];
        
        // Check if this is the first time the user launches the app
        if (isFirstUserLogin) {
            
            [self didLogInWithTwitter:user];
            [self didLogInWithFacebook:user];
            
            InterestCollectionViewFlowLayout *layoutFlow = [[InterestCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(159.5,42)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            FTInterestsViewController *rootViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:layoutFlow];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        } else {
            // Returning User
            
            // save the total number of rewards the user has earned
            PFQuery *queryPosts = [PFQuery queryWithClassName:kFTPostClassKey];
            [queryPosts whereKey:kFTPostUserKey equalTo:user];
            [queryPosts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSNumber *count = [NSNumber numberWithUnsignedInteger:objects.count];
                    NSNumber *rewardCount = [NSNumber numberWithUnsignedInteger:(objects.count / 10)];
                    [user setObject:count forKey:kFTUserPostCountKey];
                    [user setObject:rewardCount forKey:kFTUserRewardsEarnedKey];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"error %@",error);
                            [user saveEventually];
                        }
                    }];
                }
            }];
            
            ******
            // Homeviewcontroller feed
            FeedCollectionViewFlowLayout *layoutFlow = [[FeedCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(320,320)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            FTFeedViewController *rootViewController = [[FTFeedViewController alloc] initWithClassName:kFTPostClassKey];
            FTNavigationController *navController = [[FTNavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class]
                                                                                                  toolbarClass:[FTToolBar class]];
            [navController setViewControllers:@[rootViewController] animated:NO];
            
            // Present the Home View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            ******
            
            // Map Home View
            FTMapViewController *rootViewController = [[FTMapViewController alloc] init];
            FTNavigationController *navController = [[FTNavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class]
                                                                                                  toolbarClass:[FTToolBar class]];
            [navController setViewControllers:@[rootViewController] animated:NO];
            //[rootViewController setInitialLocation:locationManager.location];
            [self presentViewController:navController animated:NO completion:nil];
        }
        
    } else {
        
        // Customize the Log In View Controller
        logInViewController = [[FTLoginViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"email",@"public_profile",@"user_friends"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton;
        
 
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}
*/

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
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    PFUser *user = [PFUser currentUser];
    if (user) {
        CLLocation *location = [locations lastObject];
        //NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
        
        user[@"location"] = geoPoint;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //NSLog(@"User location updated successfully.");
            }
        }];
    }
}

@end
