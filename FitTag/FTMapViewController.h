//
//  FTMapViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/11/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchHeaderView.h"
#import <CoreLocation/CoreLocation.h>
#import "FTToolbar.h"
#import "FTMapScrollViewItem.h"
#import "FTFollowFriendsViewController.h"
#import "FTLocationManager.h"
#import "FTAmbassadorAnnotationView.h"
#import "FTBusinessAnnotationView.h"
#import "FTSuggestionCell.h"

@interface FTMapViewController : UIViewController <FTSearchHeaderViewDelegate,
                                                   FTMapScrollViewItemDelegate,
                                                   MKMapViewDelegate,
                                                   UIScrollViewDelegate,
                                                   UISearchBarDelegate,
                                                   UITextFieldDelegate,
                                                   FTAmbassadorAnnotationViewDelegate,
                                                   FTBusinessAnnotationViewDelegate,
                                                   FTSuggestionCellDelegate,
                                                   FTLocationManagerDelegate>
@property (nonatomic, strong) PFObject *user;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic) BOOL skipAnimation;

- (void)setInitialLocation:(CLLocation *)aLocation;
- (void)setInitialLocationObject:(PFObject *)object;


- (void)didTapSearchUsers:(PFUser *)aUser;
- (void)didTapSearchHashtags:(NSString *)hashtag;
- (void)didTapSearch:(NSString *)searchText forUser:(BOOL)isUser;

@end
