//
//  FTAmbassadorPinAnnotationView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/15/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FTAmbassadorAnnotationViewDelegate;
@interface FTAmbassadorAnnotationView : MKAnnotationView <MKAnnotation>

//- (id)initWithObject:(PFObject *)aObject;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic) int position;
@property (nonatomic, weak) id<FTAmbassadorAnnotationViewDelegate> delegate;
@end

@protocol FTAmbassadorAnnotationViewDelegate <NSObject>
@optional

- (void)ambassadorAnnotationView:(FTAmbassadorAnnotationView *)ambassadorAnnotationView didTapAmbassadorAnnotationView:(id)sender;

@end
