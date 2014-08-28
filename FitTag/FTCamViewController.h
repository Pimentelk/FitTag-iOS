//
//  FTCameraViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/10/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FTEditPhotoViewController.h"

@protocol FTCamViewControllerDelegate;

@interface FTCamViewController : UIViewController <FTEditPhotoViewControllerDelegate>
@property (nonatomic,weak) id <FTCamViewControllerDelegate> delegate;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@end

@protocol FTCamViewControllerDelegate <NSObject>
@optional
- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption;
@end