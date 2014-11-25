//
//  VideoEncoder.m
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "FTVideoEncoder.h"

@implementation FTVideoEncoder

@synthesize path = _path;

+ (FTVideoEncoder *)encoderForPath:(NSString*)path Height:(long)cy width:(long)cx channels:(int)ch samples:(Float64)rate {
    FTVideoEncoder *enc = [FTVideoEncoder alloc];
    [enc initPath:path Height:cy width:cx channels:ch samples:rate];
    return enc;
}


- (void) initPath:(NSString*)path
           Height:(long)cy
            width:(long)cx
         channels:(int)ch
          samples:(Float64)rate {
    
    //NSLog(@"cy: %ld",cy);
    //NSLog(@"cx: %ld",cx);
    
    self.path = path;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
    
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithLong: cx], AVVideoWidthKey,
                              [NSNumber numberWithLong: cy], AVVideoHeightKey,
                              nil];
    /*
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:cx], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:cx], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
                                                nil];
    
    NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
                                              [NSNumber numberWithInt:3],AVVideoPixelAspectRatioVerticalSpacingKey,
                                              nil];
    
    float bitsPerPixel = 11.4 * cy * cx;
    
    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:bitsPerPixel], AVVideoAverageBitRateKey,
                                   [NSNumber numberWithInt:30],AVVideoMaxKeyFrameIntervalKey,
                                   videoCleanApertureSettings, AVVideoCleanApertureKey,
                                   videoAspectRatioSettings, AVVideoPixelAspectRatioKey,
                                   //AVVideoProfileLevelH264Main30, AVVideoProfileLevelKey,
                                   nil];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   codecSettings,AVVideoCompressionPropertiesKey,
                                   [NSNumber numberWithInt:cx], AVVideoWidthKey,
                                   [NSNumber numberWithInt:cx], AVVideoHeightKey,
                                   nil];
     */
    
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_videoInput];
    
    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                          [ NSNumber numberWithInt: ch], AVNumberOfChannelsKey,
                                          [ NSNumber numberWithFloat: rate], AVSampleRateKey,
                                          [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
                nil];
    
    
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
    _audioInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_audioInput];
}

- (void) finishWithCompletionHandler:(void (^)(void))handler
{
    [_writer finishWritingWithCompletionHandler: handler];
}

- (BOOL) encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)bVideo
{
    if (CMSampleBufferDataIsReady(sampleBuffer))
    {
        if (_writer.status == AVAssetWriterStatusUnknown)
        {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed)
        {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        if (bVideo)
        {
            if (_videoInput.readyForMoreMediaData == YES)
            {
                [_videoInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
        else
        {
            if (_audioInput.readyForMoreMediaData)
            {
                [_audioInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
    }
    return NO;
}

@end
