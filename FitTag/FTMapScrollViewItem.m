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
@property (nonatomic, strong) PFObject *post;
@property (nonatomic, strong) PFObject *item;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *itemImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@end

@implementation FTMapScrollViewItem
@synthesize containerView;
@synthesize itemImageView;
@synthesize titleLabel;
@synthesize locationLabel;
@synthesize descriptionLabel;
@synthesize item;
@synthesize user;
@synthesize delegate;
@synthesize post;
@synthesize distanceLabel;

- (id)initWithFrame:(CGRect)frame AndMapItem:(PFObject *)aItem {
    self = [super initWithFrame:frame];
    if (self) {
        
        item = aItem;
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        PFFile *file;
        NSString *title;
        NSString *biography;
        PFGeoPoint *itemGeoPoint;
        UITapGestureRecognizer *itemSingleTap;
        
        if ([item objectForKey:kFTUserProfilePicSmallKey]) {
            user = (PFUser *)item;
            file = [item objectForKey:kFTUserProfilePicSmallKey];
            title = [NSString stringWithFormat:@"@%@",[user objectForKey:kFTUserDisplayNameKey]];
            itemGeoPoint = [item objectForKey:kFTUserLocationKey];
            biography = [item objectForKey:kFTUserBioKey];
            
            itemSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBusinessItemAction:)];
            itemSingleTap.numberOfTapsRequired = 1;
            
        } else if ([item objectForKey:kFTPostImageKey]) {
            post = (PFObject *)item;
            file = [item objectForKey:kFTPostImageKey];
            PFUser *postUser = [item objectForKey:kFTPostUserKey];
            title = [NSString stringWithFormat:@"@%@",[postUser objectForKey:kFTUserDisplayNameKey]];
            itemGeoPoint = [item objectForKey:kFTPostLocationKey];
            biography = nil;
            
            itemSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostItemAction:)];
            itemSingleTap.numberOfTapsRequired = 1;
        }
        
        [self addGestureRecognizer:itemSingleTap];
        
        CGSize frameSize = self.frame.size;
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
        [self addSubview:containerView];
        
        itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameSize.height, frameSize.height)];
        [itemImageView setContentMode: UIViewContentModeScaleAspectFill];
        [itemImageView setBackgroundColor:[UIColor clearColor]];
        [itemImageView setClipsToBounds:YES];
        [self.containerView addSubview:itemImageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSize.height+10, 2, frameSize.width - frameSize.height, 18)];
        [titleLabel setText:EMPTY_STRING];
        [titleLabel setFont:MULIREGULAR(14)];
        [self.containerView addSubview:titleLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSize.height+10, titleLabel.frame.size.height, frameSize.width - frameSize.height, 15)];
        [locationLabel setFont:MULIREGULAR(12)];
        [locationLabel setNumberOfLines:1];
        [locationLabel setText:EMPTY_STRING];
        [self.containerView addSubview:locationLabel];
        
        CGFloat descriptionLabelY = locationLabel.frame.size.height + locationLabel.frame.origin.y;
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSize.height+10, descriptionLabelY, frameSize.width - frameSize.height, 15)];
        [descriptionLabel setFont:MULIREGULAR(12)];
        [descriptionLabel setNumberOfLines:1];
        [descriptionLabel setText:EMPTY_STRING];
        [self.containerView addSubview:descriptionLabel];
        
        CGFloat distanceLabelY = descriptionLabel.frame.size.height + descriptionLabel.frame.origin.y;
        
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameSize.height+10, distanceLabelY, frameSize.width - frameSize.height, 15)];
        [distanceLabel setFont:MULIREGULAR(12)];
        [distanceLabel setNumberOfLines:1];
        [distanceLabel setText:EMPTY_STRING];
        [self.containerView addSubview:distanceLabel];
        
        if (![file isEqual:[NSNull null]]) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    UIImage *image = [UIImage imageWithData:data];
                    [self.itemImageView setImage:image];
                    [self.titleLabel setText:[title lowercaseString]];
                    [self.locationLabel setText:EMPTY_STRING];
                    
                    if (biography) {
                        [self.descriptionLabel setText:biography];
                    }
                    
                    // Convert Location
                    if (itemGeoPoint) {
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:itemGeoPoint.latitude longitude:itemGeoPoint.longitude];
                        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                            if (!error) {
                                for (CLPlacemark *placemark in placemarks) {
                                    NSString *postLocation = [NSString stringWithFormat:@"%@, %@", [placemark locality], [placemark administrativeArea]];
                                    if (postLocation) {
                                        [self.locationLabel setText:postLocation];
                                    }
                                }
                            } else {
                                NSLog(@"ERROR: %@",error);
                            }
                        }];
                    }
                    
                    // Calculate distance
                    if (itemGeoPoint && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
                        CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:itemGeoPoint.latitude longitude:itemGeoPoint.longitude];
                        
                        // Get the current users location
                        PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
                        CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
                        
                        // Current users distance to the item
                        [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
                    }
                }
            }];
        } else {
            
            [self.itemImageView setImage:[UIImage imageNamed:IMAGE_PROFILE_EMPTY]];
            [self.titleLabel setText:[title lowercaseString]];
            [self.locationLabel setText:EMPTY_STRING];
            
            if (biography) {
                [self.descriptionLabel setText:biography];
            }
            
            // Convert Location
            if (itemGeoPoint) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:itemGeoPoint.latitude longitude:itemGeoPoint.longitude];
                CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (!error) {
                        for (CLPlacemark *placemark in placemarks) {
                            NSString *postLocation = [NSString stringWithFormat:@"%@, %@", [placemark locality], [placemark administrativeArea]];
                            if (postLocation) {
                                [self.locationLabel setText:postLocation];
                            }
                        }
                    } else {
                        NSLog(@"ERROR: %@",error);
                    }
                }];
            }
            
            // Calculate distance
            if (itemGeoPoint && [[PFUser currentUser] objectForKey:kFTUserLocationKey]) {
                CLLocation *itemLocation = [[CLLocation alloc] initWithLatitude:itemGeoPoint.latitude longitude:itemGeoPoint.longitude];
                
                // Get the current users location
                PFGeoPoint *currentUserGeoPoint = [[PFUser currentUser] objectForKey:kFTUserLocationKey];
                CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:currentUserGeoPoint.latitude longitude:currentUserGeoPoint.longitude];
                
                // Current users distance to the item
                [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f miles",([self distanceFrom:currentUserLocation to:itemLocation]/1609.34)]];
            }
        }
    }
    return self;
}

- (void)didTapPostItemAction:(id)sender {
    NSLog(@"didTapPostItemAction:");
    if (delegate && [delegate respondsToSelector:@selector(mapScrollViewItem:didTapPostItem:post:)]){
        [delegate mapScrollViewItem:self didTapPostItem:sender post:post];
    }
}

- (void)didTapBusinessItemAction:(id)sender {
    NSLog(@"didTapBusinessItemAction:");
    if (delegate && [delegate respondsToSelector:@selector(mapScrollViewItem:didTapUserItem:user:)]){
        [delegate mapScrollViewItem:self didTapUserItem:sender user:user];
    }
}

-(CLLocationDistance)distanceFrom:(CLLocation *)postLocation to:(CLLocation *)userLocation {
    return [postLocation distanceFromLocation:userLocation];
}

@end
