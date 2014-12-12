//
//  FTCropImageViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/9/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCropImageViewController.h"

#define MIN_ZOOM_SCALE 0;
#define MAX_ZOOM_SCALE 0;

@interface FTCropImageViewController()
- (void)didTapSaveButtonAction:(id)sender;
- (void)didTapCancelButtonAction:(id)sender;
- (void)didMovedImageAction:(id)sender withEvent:(UIEvent *)event;
- (void)didTouchImageAction:(id)sender withEvent:(UIEvent *)event;
@end

@implementation FTCropImageViewController
@synthesize delegate;
@synthesize lastTouchDownPoint;

- (id)initWithPhoto:(UIImage *)aPhoto {
    self = [super init];
    if (self) {
        NSLog(@"initWithPhoto:");
        self.photo = aPhoto;
        
        self.minZoomScale = MIN_ZOOM_SCALE;
        self.maxZoomScale = MAX_ZOOM_SCALE;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad:");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:@"Crop Image"];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Override the back idnicator
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    
    // Save Button
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(didTapSaveButtonAction:)];
    [doneButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    // Cancel Button
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(didTapCancelButtonAction:)];
    [cancelButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:cancelButtonItem];
    
    // Photo Cropper
    
    //CGFloat offsetY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    CGSize viewSize = self.view.frame.size;
    
    // Photo
    
    if (!self.photo) {
        NSLog(@"Photo is nil..");
        return;
    }
    
    CGRect imageViewFrame = CGRectMake(0, 0, viewSize.width, viewSize.width);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.image = self.photo;
    self.imageView = imageView;
    
    [self.view addSubview:imageView];
    
    // Crop button
    
    self.cropRectangleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cropRectangleButton setFrame:CGRectMake(0, 0, viewSize.width, viewSize.width/2)];
    [self.cropRectangleButton setAlpha:0.6];
    [self.cropRectangleButton setBackgroundColor:FT_RED];
    
    [self.cropRectangleButton addTarget:self
                                 action:@selector(didTouchImageAction:withEvent:)
                       forControlEvents:UIControlEventTouchDown];
    [self.cropRectangleButton addTarget:self
                                 action:@selector(didMovedImageAction:withEvent:)
                       forControlEvents:UIControlEventTouchDragInside];
    
    [self.view addSubview:self.cropRectangleButton];
    
}

#pragma UIScrollViewDelegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Private Methods

- (UIImage *)croppedPhoto {
    
    
    CGRect rect = self.cropRectangleButton.frame;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [self.imageView.image drawInRect:drawRect];
    
    // grab image
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
    
}

- (void)didTapSaveButtonAction:(id)sender {
    //[self croppedPhoto];
    //return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropImageViewController:didCropPhotoAction:)]) {
        [self.delegate cropImageViewController:self didCropPhotoAction:[self croppedPhoto]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCancelButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropImageViewController:didTapCancelButton:)]) {
        [self.delegate cropImageViewController:self didTapCancelButton:sender];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTouchImageAction:(id)sender withEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    lastTouchDownPoint = point;
    NSLog(@"imageTouch. point: %@", NSStringFromCGPoint(point));
    
}

- (void)didMovedImageAction:(id)sender withEvent:(UIEvent *)event {
    
    CGRect viewRect = self.view.frame;
    
    CGFloat offsetTop = viewRect.origin.y + (self.cropRectangleButton.frame.size.height / 2);
    CGFloat offsetBottom = self.imageView.frame.size.height + self.imageView.frame.origin.y - (self.cropRectangleButton.frame.size.height / 2);
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    
    // Define boudns
    
    point.x = self.view.frame.size.width / 2;
    
    if (point.y < offsetTop) {
        point.y = offsetTop;
    }
    
    if (point.y > offsetBottom) {
        point.y = offsetBottom;
    }
    
    NSLog(@"point: x:%f y:%f",point.x,point.y);
    
    control.center = point;
}

@end
