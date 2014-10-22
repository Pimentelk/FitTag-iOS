//
//  FTCameraViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/10/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTCamFlashButtonStateNone = 0,
    FTCamFlashButtonStateOff = 1 << 0,
    FTCamFlashButtonStateOn = 1 << 1,
    FTCamFlashButtonStateAuto = 1 << 2,
    FTCamFlashButtonStateDefault = FTCamFlashButtonStateAuto
} FTCamFlashButtonState;

#import <AssetsLibrary/AssetsLibrary.h>
#import "FTEditPhotoViewController.h"
#import "FTEditVideoViewController.h"

@protocol FTCamViewControllerDelegate;

@interface FTCamViewController : UIViewController <FTEditPhotoViewControllerDelegate,FTEditVideoViewControllerDelegate>
@property (nonatomic,weak) id <FTCamViewControllerDelegate> delegate;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@end

@protocol FTCamViewControllerDelegate <NSObject>
@optional
- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption;
@end