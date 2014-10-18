//
//  FTAmbassadorPinAnnotationView
//  FitTag
//
//  Created by Kevin Pimentel on 10/15/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTAmbassadorAnnotationView.h"

@interface FTAmbassadorAnnotationView ()

@property (nonatomic, strong) PFUser *user;

@end

@implementation FTAmbassadorAnnotationView

@synthesize user;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

#pragma mark - Initialization

- (id)initWithObject:(PFUser *)aObject {
    self = [super init];
    if (self) {
        user = aObject;
        
        PFGeoPoint *geoPoint = self.user[kFTUserLocationKey];
        [self setGeoPoint:geoPoint];
    }
    return self;
}

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude
                                                  longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
}

#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = self.user[kFTUserDisplayNameKey];
}

@end