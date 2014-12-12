//
//  FTCropImageViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 12/9/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTCropImageViewControllerDelegate;
@interface FTCropImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<FTCropImageViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *cropRectangleButton;

@property CGFloat minZoomScale;
@property CGFloat maxZoomScale;

@property CGPoint lastTouchDownPoint;

- (id) initWithPhoto:(UIImage *)aPhoto;

@end

@protocol FTCropImageViewControllerDelegate <NSObject>
@optional

- (void)cropImageViewController:(FTCropImageViewController *)cropImageViewController
             didCropPhotoAction:(UIImage *)photo;

- (void)cropImageViewController:(FTCropImageViewController *)cropImageViewController
             didTapCancelButton:(UIButton *)photoCropper;

@end
