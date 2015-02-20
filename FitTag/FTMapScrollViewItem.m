//
//  FTAccountHeaderView+FTMapScrollViewItem.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapScrollViewItem.h"
#import "FTPostDetailsViewController.h"

@interface FTMapScrollViewItem()

@property (nonatomic, strong) PFUser *contact;
@property (nonatomic, strong) PFObject *place;

@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@end

@implementation FTMapScrollViewItem
@synthesize delegate;
@synthesize contact;
@synthesize place;
@synthesize locationLabel;
@synthesize distanceLabel;

- (id)initWithFrame:(CGRect)frame
              place:(PFObject *)aPlace {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        place = aPlace;
        contact = nil;
        PFFile *file = nil;
        NSString *title = EMPTY_STRING;
        NSString *biography = EMPTY_STRING;
        PFGeoPoint *itemGeoPoint = nil;
        
        if ([place objectForKey:kFTPlaceIconKey]) {
            file = [place objectForKey:kFTPlaceIconKey];
        }
        
        if ([place objectForKey:kFTPlaceContactKey]) {
            contact = [place objectForKey:kFTPlaceContactKey];
        }
        
        if ([place objectForKey:kFTPlaceNameKey]) {
            title = [place objectForKey:kFTPlaceNameKey];
        }
        
        if ([place objectForKey:kFTPlaceDescriptionKey]) {
            biography = [place objectForKey:kFTPlaceDescriptionKey];
        }
        
        if ([place objectForKey:kFTPlaceLocationKey]) {
            itemGeoPoint = [place objectForKey:kFTPlaceLocationKey];
        }
        
        // fetch image data
        if (![file isEqual:[NSNull null]]) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    // Configure the views
                    CGSize frameSize = self.frame.size;
                    
                    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
                    [self addSubview:containerView];
                    
                    // Icon Image
                    CGFloat frameSizeX = frameSize.height + 10;
                    CGFloat frameSizeW = frameSize.width - frameSize.height;
                    
                    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameSize.height, frameSize.height)];
                    [iconImageView setImage:nil];
                    [iconImageView setContentMode: UIViewContentModeScaleAspectFill];
                    [iconImageView setBackgroundColor:[UIColor clearColor]];
                    [iconImageView setClipsToBounds:YES];
                    [containerView addSubview:iconImageView];
                    [iconImageView setImage:[UIImage imageWithData:data]];
                    
                    // Title Label
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSizeX, 2, frameSizeW, 18)];
                    [titleLabel setText:title];
                    [titleLabel setFont:MULIREGULAR(14)];
                    [containerView addSubview:titleLabel];
                    
                    // Location Label
                    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSizeX, titleLabel.frame.size.height, frameSizeW, 15)];
                    [locationLabel setFont:MULIREGULAR(12)];
                    [locationLabel setNumberOfLines:1];
                    [locationLabel setText:EMPTY_STRING];
                    [containerView addSubview:locationLabel];
                    
                    // Description Label
                    CGFloat descriptionLabelY = locationLabel.frame.size.height + locationLabel.frame.origin.y;
                    
                    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSizeX, descriptionLabelY, frameSizeW, 15)];
                    [descriptionLabel setFont:MULIREGULAR(12)];
                    [descriptionLabel setNumberOfLines:1];
                    [descriptionLabel setText:biography];
                    [containerView addSubview:descriptionLabel];
                    
                    // Distance Label
                    CGFloat distanceLabelY = descriptionLabel.frame.size.height + descriptionLabel.frame.origin.y;
                    
                    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSizeX, distanceLabelY, frameSizeW, 15)];
                    [distanceLabel setFont:MULIREGULAR(12)];
                    [distanceLabel setNumberOfLines:1];
                    [distanceLabel setText:EMPTY_STRING];
                    [containerView addSubview:distanceLabel];
                    
                    [self convertLocationForPoint:itemGeoPoint];
                    [self calculateDistanceForPoint:itemGeoPoint];
                }
            }];
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPlaceAction:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)convertLocationForPoint:(PFGeoPoint *)point {
    
    if (point) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                for (CLPlacemark *placemark in placemarks) {
                    NSString *postLocation = [NSString stringWithFormat:@"%@, %@", [placemark locality], [placemark administrativeArea]];
                    if (postLocation) {
                        [locationLabel setText:postLocation];
                    }
                }
            } else {
                NSLog(@"ERROR: %@",error);
            }
        }];
    }
}

- (void)calculateDistanceForPoint:(PFGeoPoint *)point {
    
    if (point && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
        
        CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        
        // Get the current users location
        PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
        CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
        
        // Current users distance to the item
        [distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
    }
}

- (void)didTapPlaceAction:(id)sender {
    //NSLog(@"didTapBusinessItemAction:");
    if (delegate && [delegate respondsToSelector:@selector(mapScrollViewItem:didTapPlace:contact:)]){
        [delegate mapScrollViewItem:self didTapPlace:place contact:self.contact];
    }
}

-(CLLocationDistance)distanceFrom:(CLLocation *)postLocation to:(CLLocation *)userLocation {
    return [postLocation distanceFromLocation:userLocation];
}

@end
