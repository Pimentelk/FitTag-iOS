//
//  FTPlaceGeoPointAnnotation.h
//  FitTag
//
//  Created by Kevin Pimentel on 2/6/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FTPlaceGeoPointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, strong) PFFile *file;
@property (nonatomic, strong) NSString *objectId;

- (id)initWithPlace:(PFObject *)aPlace;

@end
