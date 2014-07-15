//
//  CameraImagePickerViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageCollectionViewController : UICollectionViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) void (^onCompletion)(id result);
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
