//
//  UITableView+FTCamEngine.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/15/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@protocol FTCamEngineDelegate;
@interface FTCamEngine : NSObject

+ (FTCamEngine *)engine;
- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer *)getPreviewLayer;

- (void)startCapture;
- (void)pauseCapture;
- (void)stopCapture;
- (void)resumeCapture;

- (void)captureStillImage;
- (void)switchCamera;

@property (nonatomic, weak) id <FTCamEngineDelegate> delegate;

@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;

@end

@protocol FTCamEngineDelegate <NSObject>
@required

/*!
 Sent to the delegate when a still image is captured
 @param the image that was captured
 */
- (void)cameraEngine:(FTCamEngine *)cameraEngine capturedImage:(UIImage *)image;

/*!
 Sent to the delegate when a video is captured
 @param the video that was captured
 */
- (void)cameraEngine:(FTCamEngine *)cameraEngine capturedVideoData:(NSData *)data path:(NSString *)path;

@end