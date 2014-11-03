//
//  FTAccountHeaderView+FTMapScrollViewItem.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapScrollViewItem.h"
#import "FTPostDetailsViewController.h"

@interface FTMapScrollViewItem() {
    
}
@end

@implementation FTMapScrollViewItem
@synthesize containerView;
@synthesize itemImageView;
@synthesize titleLabel;
@synthesize locationLabel;
@synthesize item;
@synthesize user;
@synthesize delegate;
@synthesize post;

- (id)initWithFrame:(CGRect)frame AndMapItem:(PFObject *)aItem {
    self = [super initWithFrame:frame];
    if (self) {
        
        item = aItem;
        
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        
        PFFile *file;
        NSString *title;
        PFGeoPoint *userGeoPoint;
        UITapGestureRecognizer *itemSingleTap;
        
        if ([item objectForKey:kFTUserProfilePicSmallKey]) {
            user = (PFUser *)item;
            file = [item objectForKey:kFTUserProfilePicSmallKey];
            title = [item objectForKey:kFTUserCompanyNameKey];
            userGeoPoint = [item objectForKey:kFTUserLocationKey];
            
            itemSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBusinessItemAction:)];
            itemSingleTap.numberOfTapsRequired = 1;
            
        } else if ([item objectForKey:kFTPostImageKey]) {
            post = (PFObject *)item;
            file = [item objectForKey:kFTPostImageKey];
            PFUser *postUser = [item objectForKey:kFTPostUserKey];
            title = [postUser objectForKey:kFTUserDisplayNameKey];
            userGeoPoint = [postUser objectForKey:kFTUserLocationKey];
            
            itemSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostItemAction:)];
            itemSingleTap.numberOfTapsRequired = 1;
        }
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                UIImage *image = [UIImage imageWithData:data];
                [self.itemImageView setImage:image];
                [self.titleLabel setText:[title uppercaseString]];
                [self.locationLabel setText:EMPTY_STRING];
                
                // Convert Location
                if (userGeoPoint) {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:userGeoPoint.latitude longitude:userGeoPoint.longitude];
                    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (!error) {
                            for (CLPlacemark *placemark in placemarks) {
                                NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                                if (postLocation) {
                                    [self.locationLabel setText:postLocation];
                                }
                            }
                        } else {
                            NSLog(@"ERROR: %@",error);
                        }
                    }];
                }
            }
        }];

        [self addGestureRecognizer:itemSingleTap];
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:containerView];
        
        itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, self.frame.size.height)];
        [itemImageView setContentMode: UIViewContentModeScaleAspectFill];
        [itemImageView setBackgroundColor:[UIColor clearColor]];
        [itemImageView setClipsToBounds:YES];
        [self.containerView addSubview:itemImageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemImageView.frame.size.width + 5, 5, self.frame.size.width - 120 - 5, 30)];
        [titleLabel setText:@"test"];
        [self.containerView addSubview:titleLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemImageView.frame.size.width + 5, titleLabel.frame.size.height + 5, self.frame.size.width - 120 - 5, 30)];
        [locationLabel setText:@"test"];        [self.containerView addSubview:locationLabel];
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

@end
