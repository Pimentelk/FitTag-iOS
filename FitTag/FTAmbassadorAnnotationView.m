//
//  FTAmbassadorPinAnnotationView
//  FitTag
//
//  Created by Kevin Pimentel on 10/15/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTAmbassadorAnnotationView.h"

@interface FTAmbassadorAnnotationView ()
@property (nonatomic, strong) PFObject *post;
@property (nonatomic, strong) PFUser *user;
@end

@implementation FTAmbassadorAnnotationView
@synthesize post;
@synthesize user;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize delegate;

#pragma mark - Initialization


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAmbassadorAnnotationAction:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (id)initWithObject:(PFObject *)aPost {
    self = [super init];
    if (self) {
        post = aPost;
        user = [post objectForKey:kFTPostUserKey];
        
        PFGeoPoint *geoPoint = [self.post objectForKey:kFTPostLocationKey];
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

- (void)didTapAmbassadorAnnotationAction:(UIButton *)sender {
    NSLog(@"didTapAmbassadorAnnotationAction");
    if (delegate && [delegate respondsToSelector:@selector(ambassadorAnnotationView:didTapAmbassadorAnnotationView:)]) {
        [delegate ambassadorAnnotationView:self didTapAmbassadorAnnotationView:sender];
    }
}

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = self.user[kFTUserDisplayNameKey];
}

@end