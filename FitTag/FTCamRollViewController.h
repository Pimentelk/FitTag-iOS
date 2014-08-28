//
//  CameraImagePickerViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FTEditPhotoViewController.h"

@protocol FTCamRollViewControllerDelegate;

@interface FTCamRollViewController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, FTEditPhotoViewControllerDelegate>
@property (nonatomic,weak) id <FTCamRollViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *usersBeingFollowed;
@property (nonatomic, strong) NSArray *assets;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
- (BOOL)shouldPresentPhotoCaptureController;
@end

@protocol FTCamRollViewControllerDelegate <NSObject>
@optional
- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption;
@end