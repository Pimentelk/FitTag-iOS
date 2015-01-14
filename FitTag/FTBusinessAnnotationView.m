//
//  FTGeoQueryAnnotation.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/14/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessAnnotationView.h"
//#import "FTBusinessGeoPointAnnotation.h"

#define BUSINESS_MAP_ICON @"business_map_icon"

// Annotation FRAME
#define SELF_FRAME_WIDTH 30
#define SELF_FRAME_HEIGHT 30
#define SELF_FRAME_X 0
#define SELF_FRAME_Y 0

@interface FTBusinessAnnotationView ()
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation FTBusinessAnnotationView
@synthesize delegate;
@synthesize user;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize imageView;
@synthesize annotation;
@synthesize file;

#pragma mark - Initialization

- (id)initWithAnnotation:(id<MKAnnotation>)aAnnotation
                   reuseIdentifier:(NSString *)reuseIdentifier {
    
    //NSLog(@"%@::initWithAnnotation:reuseIdentifier:",VIEWCONTROLLER_BUSINESS_ANNOTATION);
    self = [super initWithAnnotation:aAnnotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        annotation = aAnnotation;
        
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(PROFILE_X, PROFILE_Y, PROFILE_WIDTH, PROFILE_HEIGHT);
        imageView.layer.cornerRadius = CORNERRADIUS(PROFILE_WIDTH);
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        
        self.canShowCallout = YES;
        self.draggable = NO;
    }
    return self;
}

- (void)setFile:(PFFile *)aFile {
    
    file = aFile;
    
    if (![file isEqual:[NSNull null]]) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                self.frame = CGRectMake(SELF_FRAME_Y, SELF_FRAME_X, SELF_FRAME_WIDTH, SELF_FRAME_HEIGHT);
                
                imageView.image = [UIImage imageWithData:data];
                
                for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
                    [self removeGestureRecognizer:recognizer];
                }
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBusinessAnnotationAction:)];
                [self addGestureRecognizer:tapGesture];
            }
        }];        
    } else {
        imageView.image = [UIImage imageNamed:IMAGE_PROFILE_EMPTY];
    }
}

/*
-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    NSLog(@"CLICKY!");
}
*/

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    //NSLog(@"%@::setCoordinate:",VIEWCONTROLLER_BUSINESS_ANNOTATION);
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
}

#pragma mark - ()

- (void)didTapBusinessAnnotationAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(businessAnnotationView:didTapBusinessAnnotationView:coordinate:)]) {
        [delegate businessAnnotationView:self
            didTapBusinessAnnotationView:sender
                              coordinate:coordinate];
    }
}

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    //NSLog(@"%@::setGeoPoint:",VIEWCONTROLLER_BUSINESS_ANNOTATION);
    coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    title = self.user[kFTUserDisplayNameKey];
}

@end