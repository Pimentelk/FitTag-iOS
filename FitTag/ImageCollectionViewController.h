//
//  CameraImagePickerViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FTCameraToolBar.h"

@interface ImageCollectionViewController : UICollectionViewController <FTCameraToolBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
- (BOOL)shouldPresentPhotoCaptureController;
@property (nonatomic,retain) NSMutableArray *usersBeingFollowed;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) void (^onCompletion)(id result);
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
