//
//  FTCameraViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/10/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCameraEngine.h"
#import "FTVideoEncoder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FTEditPhotoViewController.h"
#import "FTEditVideoViewController.h"
#import "FTCamRollViewController.h"

typedef enum {
    FTCamFlashButtonStateNone = 0,
    FTCamFlashButtonStateOff = 1 << 0,
    FTCamFlashButtonStateOn = 1 << 1,
    FTCamFlashButtonStateAuto = 1 << 2,
    FTCamFlashButtonStateDefault = FTCamFlashButtonStateAuto
} FTCamFlashButtonState;

@protocol FTCamViewControllerDelegate;

@interface FTCamViewController : UIViewController <FTCamRollViewControllerDelegate,FTCameraEngineDelegate>
@property (nonatomic, weak) id <FTCamViewControllerDelegate> delegate;
@property (nonatomic) BOOL isProfilePciture;
@property (nonatomic) BOOL isCoverPhoto;

@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;
@end

@protocol FTCamViewControllerDelegate <NSObject>
@optional
- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo;
- (void)camViewController:(FTCamViewController *)camViewController coverPhoto:(UIImage *)photo;
@end