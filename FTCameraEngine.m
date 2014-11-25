//  FTCameraEngine.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCameraEngine.h"
#import "FTVideoEncoder.h"
#import "AssetsLibrary/ALAssetsLibrary.h"

static void *CapturingPausedChangedContext = &CapturingPausedChangedContext;

static FTCameraEngine *theEngine;

@interface FTCameraEngine () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    FTVideoEncoder *_encoder;
    BOOL _isCapturing;
    BOOL _isPaused;
    BOOL _discont;
    int _currentFile;
    CMTime _timeOffset;
    CMTime _progressTime;
    CMTime _lastVideo;
    CMTime _lastAudio;
    long _cx;
    long _cy;
    int _channels;
    Float64 _samplerate;
}

@end

@implementation FTCameraEngine
@synthesize delegate;

@synthesize isCapturing = _isCapturing;
@synthesize isPaused = _isPaused;

+ (void) initialize {
    // test recommended to avoid duplicate init via subclass
    if (self == [FTCameraEngine class]) {
        theEngine = [[FTCameraEngine alloc] init];
    }
}

+ (FTCameraEngine *)engine {
    return theEngine;
}

- (void)startup {
    NSLog(@"startUp");
    if (self.session == nil) {
        NSLog(@"Starting up server");
        self.isCapturing = NO;
        self.isPaused = NO;
        _currentFile = 0;
        _discont = NO;
        self.maxDuration = 10;
        
        // create capture device with video input
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        [session setSessionPreset:AVCaptureSessionPresetMedium];
        [self setSession:session];
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([self.session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [self.session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }

        AVCaptureDevice *backCamera = [FTCameraEngine deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
        if ([self.session canAddInput:input]) {
            [self.session addInput:input];
            [self setVideoDeviceInput:input];
        }
        
        // create an output for YUV output with self as delegate
        self.captureQueue = dispatch_queue_create("camera.engine.session_queue", DISPATCH_QUEUE_SERIAL);
        
        AVCaptureVideoDataOutput *videoout = [[AVCaptureVideoDataOutput alloc] init];
        [videoout setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary *setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
        videoout.videoSettings = setcapSettings;
        if ([self.session canAddOutput:videoout]) {
            [self.session addOutput:videoout];
            [self setVideoDataOutput:videoout];
        }
        self.videoConnection = [videoout connectionWithMediaType:AVMediaTypeVideo];
        [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        // find the actual dimensions used so we can set up the encoder to the same.
        NSDictionary *actual = videoout.videoSettings;
        _cy = [[actual objectForKey:@"Height"] integerValue];
        _cx = [[actual objectForKey:@"Width"] integerValue];
        
        // audio input from default mic
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        if ([self.session canAddInput:audioDeviceInput]) {
            [self.session addInput:audioDeviceInput];
            [self setAudioDeviceInput:audioDeviceInput];
        }
        AVCaptureAudioDataOutput *audioDeviceDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [audioDeviceDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
        [self.session addOutput:audioDeviceDataOutput];
        self.audioConnection = [audioDeviceDataOutput connectionWithMediaType:AVMediaTypeAudio];
        // for audio, we want the channels and sample rate, but we can't get those from audioout.audiosettings on ios, so
        // we need to wait for the first sample
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(subjectAreaDidChange:)
                                                     name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object:[[self videoDeviceInput] device]];
        
        [self addObserver:self
               forKeyPath:@"isPaused"
                  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context:CapturingPausedChangedContext];
        
        // start capture and a preview layer
        [self.session startRunning];
        NSLog(@"session:%@",self.session);
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == CapturingPausedChangedContext) {
        if (delegate && [delegate respondsToSelector:@selector(cameraEngine:recordingStatusChange:)]) {
            [delegate cameraEngine:self recordingStatusChange:self.isPaused];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)startCapture {
    NSLog(@"startCapture");
    @synchronized(self){
            if (!self.isCapturing) {
                    // create the encoder once we have the audio params
                    _encoder = nil;
                    self.isPaused = NO;
                    _discont = NO;
                    _timeOffset = CMTimeMake(0,0);
                    _progressTime = CMTimeMake(0,0);
                    self.isCapturing = YES;
                }
        }
}

- (void)stopCapture {
    NSLog(@"stopCapture");
    @synchronized(self) {
        if (self.isCapturing) {
            
            NSString *filename = [NSString stringWithFormat:@"capture%d.mp4", _currentFile];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            NSURL *url = [NSURL fileURLWithPath:path];
            _currentFile++;
            
            NSLog(@"filename:%@",filename);
            NSLog(@"path:%@",path);
            NSLog(@"url:%@",url);
            NSLog(@"_currentFile:%d",_currentFile);
            
            // serialize with audio and video capture
            self.isCapturing = NO;
            dispatch_async(self.captureQueue, ^{
                [_encoder finishWithCompletionHandler:^{
                    self.isCapturing = NO;
                    _encoder = nil;
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    
                    //NSLog(@"library %@",library);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [library writeVideoAtPathToSavedPhotosAlbum:url
                                                    completionBlock:^(NSURL *assetURL, NSError *error){
                                                        if (error) {
                                                            NSLog(@"error: %@",error);
                                                            return;
                                                        }
                                                        
                                                        NSData *videoData = [NSData dataWithContentsOfURL:url];
                                                        if ([videoData length] > 10485760) {
                                                            [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                        message:@"Your video is too large."
                                                                                       delegate:nil
                                                                              cancelButtonTitle:nil
                                                                              otherButtonTitles:@"Dismiss", nil] show];
                                                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                                                            return;
                                                        }
                                                        
                                                        if (delegate && [delegate respondsToSelector:@selector(cameraEngine:capturedVideoData:path:)]) {
                                                            [delegate cameraEngine:self capturedVideoData:videoData path:path];
                                                        }
                                                        
                                                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                                                    }];
                    });
                }];
            });
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Message"
                                        message:@"You have not recorded a video."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Dismiss", nil] show];
        }
    }
}

- (void)pauseCapture {
    NSLog(@"pauseCapture");
    @synchronized(self) {
        if (self.isCapturing) {
            self.isPaused = YES;
            _discont = YES;
        }
    }
}

- (void)resumeCapture {
    NSLog(@"resumeCapture");
    @synchronized(self) {
        if (self.isPaused) {
            self.isPaused = NO;
        }
    }
}

- (void)setAudioFormat:(CMFormatDescriptionRef)fmt {
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _samplerate = asbd->mSampleRate;
    _channels = asbd->mChannelsPerFrame;
}

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    
    return sout;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    BOOL bVideo = YES;
    
    @synchronized(self) {
        
        if (!self.isCapturing  || self.isPaused) {
            return;
        }
        
        //if (delegate && [delegate respondsToSelector:@selector(cameraEngine:progressStatusUpdate:)]) {
        //    [delegate cameraEngine:self progressStatusUpdate:videoData];
        //}
        
        if (connection != self.videoConnection)
            bVideo = NO;
        
        if ((_encoder == nil) && !bVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            NSLog(@"fmt: %@",fmt);
            [self setAudioFormat:fmt];
            NSString *filename = [NSString stringWithFormat:@"capture%d.mp4", _currentFile];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            _encoder = [FTVideoEncoder encoderForPath:path Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
        
        if (_discont) {
            
            if (bVideo)
                return;
            
            _discont = NO;
            // calc adjustment
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            
            CMTime last = bVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (_timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                NSLog(@"Setting offset from %s", bVideo?"video": "audio");
                NSLog(@"Adding %f to %f (pts %f)", ((double)offset.value)/offset.timescale, ((double)_timeOffset.value)/_timeOffset.timescale, ((double)pts.value/pts.timescale));
                // this stops us having to set a scale for _timeOffset before we see the first video time
                if (_timeOffset.value == 0) {
                    _timeOffset = offset;
                } else {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        
        // Update progress view

        CMTime previousTimeScale = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        CMTime last = bVideo ? _lastVideo : _lastAudio;
        if (last.flags & kCMTimeFlags_Valid) {
            if (_timeOffset.flags & kCMTimeFlags_Valid) {
                previousTimeScale = CMTimeSubtract(previousTimeScale, _timeOffset);
            }
            CMTime offset = CMTimeSubtract(previousTimeScale, last);
            // this stops us having to set a scale for _timeOffset before we see the first video time
            if (_progressTime.value == 0) {
                _progressTime = offset;
            } else {
                _progressTime = CMTimeAdd(_progressTime, offset);
            }
        }
        
        CGFloat seconds = ((double)_progressTime.value)/_progressTime.timescale;
        
        if (seconds > 0 && !isnan(seconds)) {
            if (delegate && [delegate respondsToSelector:@selector(cameraEngine:progressStatusUpdate:)]) {
                [delegate cameraEngine:self progressStatusUpdate:seconds];
            }
        }
        
        NSLog(@"seconds:%f",((double)_progressTime.value)/_progressTime.timescale);
        if (seconds >= 10) {
            // Stop it
            [self pauseCapture];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Message"
                                            message:@"You've reached the video limit (10 seconds)."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Ok", nil] show];
                
                if (delegate && [delegate respondsToSelector:@selector(cameraEngine:recordingStatusChange:)]) {
                    [delegate cameraEngine:self recordingStatusChange:self.isPaused];
                }
            });
            return;
        }
        
        // retain so that we can release either this or modified one
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        // record most recent time so we know the length of the pause
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        
        if (dur.value > 0)
            pts = CMTimeAdd(pts, dur);
        
        if (bVideo)
            _lastVideo = pts;
        else
            _lastAudio = pts;
    }
    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer isVideo:bVideo];
    CFRelease(sampleBuffer);
}

- (void)shutdown {
    NSLog(@"shutting down server");
    if (self.session) {
        [self.session stopRunning];
        self.session = nil;
    }
    [_encoder finishWithCompletionHandler:^{
        NSLog(@"Capture completed");
    }];
}

- (AVCaptureVideoPreviewLayer *)getPreviewLayer {
    return self.preview;
}

- (void)switchCamera {
    NSLog(@"switchCamera");
    dispatch_async(self.captureQueue, ^{
        // * Capture Device * //
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *captureDevice = [devices firstObject];
        for (AVCaptureDevice *device in devices) {
            if ([device position] == preferredPosition) {
                captureDevice = device;
                break;
            }
        }
        
        if ([captureDevice lockForConfiguration:nil]) {
            [captureDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [captureDevice unlockForConfiguration];
        }
        
        // * VIDEO DATA INPUT * //
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        
        [self.session beginConfiguration];
        [self.session removeInput:[self videoDeviceInput]];
        [self.session setSessionPreset:AVCaptureSessionPresetMedium];
        
        if ([self.session canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
            
            [self.session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        } else {
            [self.session addInput:[self videoDeviceInput]];
        }
        
        // * VIDEO DATA OUTPUT * //
        [self.session removeOutput:[self videoDataOutput]];
        self.videoDataOutput = nil;
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        NSDictionary *setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
        self.videoDataOutput.videoSettings = setcapSettings;
        if ([self.session canAddOutput:self.videoDataOutput]) {
            [self.session addOutput:self.videoDataOutput];
            self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
            [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [[self videoDataOutput] setSampleBufferDelegate:self queue:self.captureQueue];
        
        NSLog(@"session:%@",self.session);
        [self.session commitConfiguration];
    });
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    //NSLog(@"setFlashMode - flashMode:%d",flashMode);
    [FTCameraEngine setFlashMode:flashMode forDevice:[[self videoDeviceInput] device]];
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode
           forDevice:(AVCaptureDevice *)device {
    
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            //NSLog(@"Flash mode updated to: %ld",flashMode);
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        } else {
            NSLog(@" setFlashMode: %@", error);
        }
    } else {
        NSLog(@" Device does not have flash or flash is not supported.");
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    NSLog(@"subjectAreaDidChange");
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
         exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
       exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    NSLog(@"focusWithMode:exposeWithMode:atDevicePoint:monitorSubjectAreaChange:");
    dispatch_async(self.captureQueue, ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    });
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType
                      preferringPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

- (void)captureStillImage {
    dispatch_async(self.captureQueue, ^{
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo]
                                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                                 //NSLog(@"imageDataSampleBuffer: %@",imageDataSampleBuffer);
                                                                 if (!error) {
                                                                     if (imageDataSampleBuffer) {
                                                                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                         UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                         UIImage *croppedImage = [self squareImageFromImage:image scaledToSize:320.0f];
                                                                         if (delegate && [delegate respondsToSelector:@selector(cameraEngine:capturedImage:)]) {
                                                                             [delegate cameraEngine:self capturedImage:croppedImage];
                                                                         }
                                                                     }
                                                                 } else {
                                                                     NSLog(@"FTCameraEngine::error: %@", error);
                                                                 }
                                                             }];
    });
}



- (UIImage *)squareImageFromImage:(UIImage *)image
                     scaledToSize:(CGFloat)newSize {
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.preview setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [self.preview setOpacity:1.0];
        }];
    });
}

#pragma mark - ()


- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[FTCameraEngine engine] getPreviewLayer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus
         exposeWithMode:AVCaptureExposureModeAutoExpose
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

@end

