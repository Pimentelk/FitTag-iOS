//
//  UIView+FTLocationManager.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLocationManager.h"

@implementation FTLocationManager
@synthesize locationManager;
@synthesize delegate;

#pragma mark - CLLocationManagerDelegate

- (void)requestLocationAuthorization {
    // Update the users location
    NSLog(@"requestLocationAuthorization:");
    if (IS_OS_8_OR_LATER) {
        [[self locationManager] requestAlwaysAuthorization];
    }
    [[self locationManager] startUpdatingLocation];
}

- (CLLocationManager *)locationManager {
    //NSLog(@"FTLocationManager::locationManager");
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
    NSLog(@"FTLocationManager::didFailWithError: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Failed to Get Your Location"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"FTLocationManager::locationManager:didUpdateLocations:");
    [locationManager stopUpdatingLocation];
    if ([PFUser currentUser]) {
        CLLocation *location = [locations lastObject];
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
        
        if (delegate && [delegate respondsToSelector:@selector(locationManager:didUpdateUserLocation:geoPoint:)]){
            [delegate locationManager:self didUpdateUserLocation:location geoPoint:geoPoint];
        }
        
        [[PFUser currentUser] setValue:geoPoint forKey:kFTUserLocationKey];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //NSLog(@"%@::locationManager:didUpdateLocations: - User location updated successfully.",VIEWCONTROLLER_MAP);
            }
        }];
    }
}

@end
