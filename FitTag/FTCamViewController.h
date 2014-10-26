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
#import "FTCamRollViewController.h"

@protocol FTCamViewControllerDelegate;

@interface FTCamViewController : UIViewController <FTCamRollViewControllerDelegate>
@property (nonatomic,weak) id <FTCamViewControllerDelegate> delegate;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) BOOL isProfilePciture;
@end

@protocol FTCamViewControllerDelegate <NSObject>
@optional
- (void)camViewController:(FTCamViewController *)camViewController photo:(UIImage *)photo;
@end