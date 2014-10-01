//
//  FTEditPhotoViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"
#import <CoreLocation/CoreLocation.h>

@protocol FTEditVideoViewControllerDelegate;

@interface FTEditVideoViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate,FTPostDetailsFooterViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,weak) id <FTEditVideoViewControllerDelegate> delegate;
/// The Play Video button
@property (nonatomic,readonly) UIButton *playButton;
- (id)initWithVideo:(NSData *)aVideo;
@end

@protocol FTEditVideoViewControllerDelegate <NSObject>
@optional

@end