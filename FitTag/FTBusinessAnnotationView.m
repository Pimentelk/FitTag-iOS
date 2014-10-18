//
//  FTGeoQueryAnnotation.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/14/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessAnnotationView.h"
#import "FTBusinessGeoPointAnnotation.h" 

#define BUSINESS_MAP_ICON @"business_map_icon"

// Annotation FRAME
#define SELF_FRAME_WIDTH 30
#define SELF_FRAME_HEIGHT 42
#define SELF_FRAME_X 0
#define SELF_FRAME_Y 0

// Profile Hexagon
#define PROFILE_HEXAGON_WIDTH 26
#define PROFILE_HEXAGON_HEIGHT 30
#define PROFILE_HEXAGON_X 2
#define PROFILE_HEXAGON_Y 2

@interface FTBusinessAnnotationView ()
@property (nonatomic, strong) PFUser *user;
@end

@implementation FTBusinessAnnotationView

@synthesize user;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

#pragma mark - Initialization

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier {
    
    NSLog(@"%@::initWithAnnotation:reuseIdentifier:",VIEWCONTROLLER_BUSINESS_ANNOTATION_VIEW);
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"annotation: %@",annotation);
        FTBusinessGeoPointAnnotation *businessGeoPointAnnotation = annotation;
        PFFile *file = [businessGeoPointAnnotation file];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.image = [UIImage imageNamed:BUSINESS_MAP_ICON];
                self.frame = CGRectMake(SELF_FRAME_Y, SELF_FRAME_X, SELF_FRAME_WIDTH, SELF_FRAME_HEIGHT);
                
                UIImageView *profileHexagon = [FTUtility getProfileHexagonWithX:PROFILE_HEXAGON_X
                                                                              Y:PROFILE_HEXAGON_Y
                                                                          width:PROFILE_HEXAGON_WIDTH
                                                                         hegiht:PROFILE_HEXAGON_HEIGHT];
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                [imageView setFrame: profileHexagon.frame];
                [imageView.layer setMask: profileHexagon.layer.mask];
                [self addSubview:imageView];
            }
        }];
    
        self.canShowCallout = YES;
        self.draggable = NO;
    }
    return self;
}

/*
-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    NSLog(@"CLICKY!");
}
*/

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    NSLog(@"%@::setCoordinate:",VIEWCONTROLLER_BUSINESS_ANNOTATION_VIEW);
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude
                                                  longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
}

#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    NSLog(@"%@::setGeoPoint:",VIEWCONTROLLER_BUSINESS_ANNOTATION_VIEW);
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = self.user[kFTUserDisplayNameKey];
}

@end