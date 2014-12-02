//
//  FTGeoQueryAnnotation.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/14/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FTBusinessAnnotationViewDelegate;
@interface FTBusinessAnnotationView : MKAnnotationView <MKAnnotation>

//- (id)initWithObject:(PFObject *)aObject;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic) PFFile *file;
@property (nonatomic) int position;
@property (nonatomic) id<MKAnnotation> annotation;

@property (nonatomic, weak) id<FTBusinessAnnotationViewDelegate> delegate;
@end

@protocol FTBusinessAnnotationViewDelegate <NSObject>
@optional

- (void)businessAnnotationView:(FTBusinessAnnotationView *)businessAnnotationView didTapBusinessAnnotationView:(id)sender;

@end