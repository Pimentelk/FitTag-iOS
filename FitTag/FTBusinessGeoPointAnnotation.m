//
//  FTBusinessGeoPointAnnotation.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/15/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessGeoPointAnnotation.h"

@interface FTBusinessGeoPointAnnotation ()

@property (nonatomic, strong) PFUser *user;

@end

@implementation FTBusinessGeoPointAnnotation
@synthesize user;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize file;
@synthesize objectId;

#pragma mark - Initialization

- (id)initWithObject:(PFUser *)aObject {
    //NSLog(@"FTBusinessGeoPointAnnotation::initWithObject:");
    
    self = [super init];
    
    if (self) {
        
        NSLog(@"aObject:%@",aObject);
        
        user = aObject;
        objectId = user.objectId;
        file = [self.user objectForKey:kFTUserProfilePicSmallKey];
        [self setGeoPoint:[self.user objectForKey:kFTUserLocationKey]];
    }
    
    return self;
}

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    //NSLog(@"FTBusinessGeoPointAnnotation::setCoordinate:");
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
}

#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    //NSLog(@"FTBusinessGeoPointAnnotation::setGeoPoint:%@",geoPoint);
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = [self.user objectForKey:kFTUserCompanyNameKey];
}

@end
