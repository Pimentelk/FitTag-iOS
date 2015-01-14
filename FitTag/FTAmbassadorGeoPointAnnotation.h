//
//  FTMapViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FTAmbassadorGeoPointAnnotation : NSObject <MKAnnotation>

- (id)initWithObject:(PFObject *)aObject;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *objectId;

@end
