//
//  FTTabBarController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"

@protocol FTTabBarControllerDelegate;

@interface FTTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (BOOL)shouldPresentPhotoCaptureController;

@end

@protocol FTTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end