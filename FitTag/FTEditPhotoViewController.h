//
//  FTEditPhotoViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTEditPhotoViewControllerDelegate;

@interface FTEditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic,weak) id <FTEditPhotoViewControllerDelegate> delegate;
- (id)initWithImage:(UIImage *)aImage;
@end

@protocol FTEditPhotoViewControllerDelegate <NSObject>
@optional
- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption;
@end