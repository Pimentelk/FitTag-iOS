//
//  FTLocationManager.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTLocationManagerDelegate;
@interface FTLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<FTLocationManagerDelegate> delegate;

- (void)requestLocationAuthorization;

@end

@protocol FTLocationManagerDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the current users location is updated
 @param geoPoint the users current location
 */
- (void)locationManager:(FTLocationManager *)locationManager didUpdateUserLocation:(CLLocation *)location geoPoint:(PFGeoPoint *)aGeoPoint;

@end