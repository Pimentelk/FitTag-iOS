//
//  UITableView+FTCameraEngine.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"


@protocol FTCameraEngineDelegate;
@interface FTCameraEngine : NSObject

+ (FTCameraEngine *)engine;
- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer *) getPreviewLayer;

- (void)startCapture;
- (void)pauseCapture;
- (void)stopCapture;
- (void)resumeCapture;

- (void)captureStillImage;
- (void)switchCamera;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;
- (void)runStillImageCaptureAnimation;
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

@property (nonatomic, weak) id <FTCameraEngineDelegate> delegate;

@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic) AVCaptureConnection *videoConnection;
@property (nonatomic) AVCaptureConnection *audioConnection;

@property (nonatomic) dispatch_queue_t captureQueue;

@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic) CGFloat maxDuration;

@end

@protocol FTCameraEngineDelegate <NSObject>
@required


/*!
 Sent to the delegate when the recording state changes
 @param the state of recording
 */
- (void)cameraEngine:(FTCameraEngine *)cameraEngine progressStatusUpdate:(CGFloat)update;

/*!
 Sent to the delegate when the recording state changes
 @param the state of recording
 */
- (void)cameraEngine:(FTCameraEngine *)cameraEngine recordingStatusChange:(BOOL)isPaused;

/*!
 Sent to the delegate when a still image is captured
 @param the image that was captured
 */
- (void)cameraEngine:(FTCameraEngine *)cameraEngine capturedImage:(UIImage *)image;

/*!
 Sent to the delegate when a video is captured
 @param the video that was captured
 */
- (void)cameraEngine:(FTCameraEngine *)cameraEngine capturedVideoData:(NSData *)data path:(NSString *)path;

@end