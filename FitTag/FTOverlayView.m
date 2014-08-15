//
//  FTOverlay.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/9/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTOverlayView.h"

@implementation FTOverlayView 

/*
-(void)drawRect:(CGRect)rect
{
    
}
*/

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        // Camera Overlay
        UIImageView *cameraOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_overlay"]];
        [cameraOverlay setFrame:CGRectMake(0.0f, -1.0f, 320.0f, 33.0f)];
        [self addSubview:cameraOverlay];
        
        // Add crosshairs
        UIImageView *crosshairs = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crosshairs"]];
        [crosshairs setFrame:CGRectMake(0.0f, cameraOverlay.frame.size.height + cameraOverlay.frame.origin.y, 320.0f, 249.0f)];
        [self addSubview:crosshairs];
        
        // Camera Overlay
        UIView *cameraBarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0.0f, crosshairs.frame.size.height + cameraOverlay.frame.size.height + cameraOverlay.frame.origin.y - 1.0f, 320.0f, 33.0f)];
        [cameraBarOverlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_overlay"]]];
        [self addSubview:cameraBarOverlay];
        
        /*
        UIImageView *cameraBarOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_overlay"]];
        [cameraBarOverlay setFrame:CGRectMake(0.0f, crosshairs.frame.size.height + cameraOverlay.frame.size.height + cameraOverlay.frame.origin.y - 1.0f, 320.0f, 33.0f)];
        [self addSubview:cameraBarOverlay];
        */
        
        // Toggle Camera
        UIButton *toggleCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [toggleCamera setFrame:CGRectMake(0.0f, 0.0f, 26.0f, 25.0f)];
        [toggleCamera setBackgroundImage:[UIImage imageNamed:@"toggle_camera"] forState:UIControlStateNormal];
        [toggleCamera addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
        [toggleCamera setTintColor:[UIColor grayColor]];
        [toggleCamera setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Toggle Flash
        UIButton *toggleFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [toggleFlash setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 24.0f)];
        [toggleFlash setBackgroundImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        [toggleFlash addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
        [toggleFlash setTintColor:[UIColor grayColor]];
        [toggleFlash setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Toggle Crosshairs
        UIButton *toggleCrosshairs = [UIButton buttonWithType:UIButtonTypeCustom];
        [toggleCrosshairs setFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
        [toggleCrosshairs setBackgroundImage:[UIImage imageNamed:@"toggle_crosshairs"] forState:UIControlStateNormal];
        [toggleCrosshairs addTarget:self action:@selector(toggleCrosshairs:) forControlEvents:UIControlEventTouchUpInside];
        [toggleCrosshairs setTintColor:[UIColor grayColor]];
        [toggleCrosshairs setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Add buttons to the overlay bar
        [cameraBarOverlay addSubview:toggleCrosshairs];
        [cameraBarOverlay addSubview:toggleCamera];
        [cameraBarOverlay addSubview:toggleFlash];
        
        // Take picture
        UIButton *takePicture = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePicture setFrame:CGRectMake(120.0f, 340.0f, 74.0f, 74.0f)];
        [takePicture setBackgroundImage:[UIImage imageNamed:@"take_picture"] forState:UIControlStateNormal];
        [takePicture addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        [takePicture setTintColor:[UIColor grayColor]];
        [self addSubview:takePicture];
        
        // Take Video
        UIButton *takVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        [takVideo setFrame:CGRectMake(260.0f, 340.0f, 44.0f, 39.0f)];
        [takVideo setBackgroundImage:[UIImage imageNamed:@"video_button"] forState:UIControlStateNormal];
        [takVideo addTarget:self action:@selector(takVideo:) forControlEvents:UIControlEventTouchUpInside];
        [takVideo setTintColor:[UIColor grayColor]];
        [self addSubview:takVideo];
        
        // Take Video
        UIButton *cameraRoll = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameraRoll setFrame:CGRectMake(30.0f, 340.0f, 44.0f, 50.0f)];
        [cameraRoll setBackgroundImage:[UIImage imageNamed:@"camera_roll"] forState:UIControlStateNormal];
        [cameraRoll addTarget:self action:@selector(cameraRoll:) forControlEvents:UIControlEventTouchUpInside];
        [cameraRoll setTintColor:[UIColor grayColor]];
        [self addSubview:cameraRoll];
        
    }
    
    return self;
}

-(void)toggleCamera:(id)sender
{
    NSLog(@"FTOverlayView::toggleCamera");
    
}

-(void)toggleFlash:(id)sender
{
    NSLog(@"FTOverlayView::toggleFlash");
    
}

-(void)toggleCrosshairs:(id)sender
{
    NSLog(@"FTOverlayView::toggleCrosshairs");
}

-(void)takePicture:(id)sender
{
    NSLog(@"FTOverlayView::takePicture");
}

-(void)takVideo:(id)sender
{
    NSLog(@"FTOverlayView::takVideo");
}

-(void)cameraRoll:(id)sender
{
    NSLog(@"FTOverlayView::cameraRoll");
}
@end
