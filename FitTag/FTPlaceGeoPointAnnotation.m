//
//  FTPlaceGeoPointAnnotation.m
//  FitTag
//
//  Created by Kevin Pimentel on 2/6/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTPlaceGeoPointAnnotation.h"

@interface FTPlaceGeoPointAnnotation ()

@property (nonatomic, strong) PFObject *place;

@end

@implementation FTPlaceGeoPointAnnotation
@synthesize place;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize file;
@synthesize objectId;

- (id)initWithPlace:(PFObject *)aPlace {
    
    self = [super init];
    
    if (self) {
        
        place = aPlace;
        objectId = place.objectId;
        file = [self.place objectForKey:kFTPlaceIconKey];
        
        [self setGeoPoint:[self.place objectForKey:kFTPlaceLocationKey]];
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

#pragma mark -

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    //NSLog(@"FTBusinessGeoPointAnnotation::setGeoPoint:%@",geoPoint);
    //NSLog(@"%@:%@",kFTPlaceNameKey,[self.place objectForKey:kFTPlaceNameKey]);    
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = [self.place objectForKey:kFTPlaceNameKey];
}

@end
