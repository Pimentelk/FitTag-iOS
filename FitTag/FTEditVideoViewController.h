//
//  FTEditPhotoViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"

@protocol FTEditVideoViewControllerDelegate;

@interface FTEditVideoViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate,FTPostDetailsFooterViewDelegate>

@property (nonatomic,weak) id <FTEditVideoViewControllerDelegate> delegate;
- (id)initWithVideo:(NSData *)aVideo;
@end

@protocol FTEditVideoViewControllerDelegate <NSObject>
@optional

@end